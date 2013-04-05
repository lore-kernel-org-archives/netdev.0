From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] Revert "af_unix: dont send SCM_CREDENTIAL when
 dest socket is NULL"
Date: Fri, 05 Apr 2013 00:47:31 -0400 (EDT)
Message-ID: <20130405.004731.151872753500597206.davem@davemloft.net>
References: <1365035424.13853.48.camel@edumazet-glaptop>
	<878v4zjei0.fsf@xmission.com>
	<87li8zhwkw.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: svenjoac@gmx.de, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	dingtianhong@huawei.com, edumazet@google.com, luto@amacapital.net,
	ksrot@redhat.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: ebiederm@xmission.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <87li8zhwkw.fsf_-_@xmission.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 03 Apr 2013 19:13:35 -0700

> 
> This reverts commit 14134f6584212d585b310ce95428014b653dfaf6.
> 
> The problem that the above patch was meant to address is that af_unix
> messages are not being coallesced because we are sending unnecesarry
> credentials.  Not sending credentials in maybe_add_creds totally
> breaks unconnected unix domain sockets that wish to send credentails
> to other sockets.
> 
> In practice this break some versions of udev because they receive a
> message and the sending uid is bogus so they drop the message.
> 
> Cc: stable@vger.kernel.org
> Reported-by: Sven Joachim <svenjoac@gmx.de>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied.
