From: Michal Privoznik <mprivozn@redhat.com>
Subject: Re: [PATCH] net-sysfs: Report link speed as signed integer
Date: Tue, 03 Jun 2014 09:07:28 +0200
Message-ID: <538D7430.2080200@redhat.com>
References: <06d53256e3bf2d0deedb16249082200500da3ee6.1401718809.git.mprivozn@redhat.com>	<20140602143557.GA2925@minipsycho.orion>	<20140602150150.GF6295@redhat.com> <20140602.111050.54996809312556969.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, vfalico@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140602.111050.54996809312556969.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02.06.2014 20:10, David Miller wrote:
> From: Veaceslav Falico <vfalico@redhat.com>
> Date: Mon, 2 Jun 2014 17:01:50 +0200
>
>> I wonder, though, if we should document it or just output "Unknown"
>> instead of -1.
>
> All of this discussion means that we can't change the format string
> without potentially breaking something out there interpreting the -1
> value, however it gets output now.

No, the discussion means reporting -1 as link speed is confusing.

>
> I think we just have to leave things as-is and document them in the
> sysfs ABI docs.

Well, that's rather unpleasant.

>
> I'm not applying this patch.
>

Michal
