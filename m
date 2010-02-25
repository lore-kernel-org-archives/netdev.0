From: "Octavian Purdila" <opurdila@ixiacom.com>
Subject: Re: [net-next PATCH v5 2/3] sysctl: add proc_do_large_bitmap
Date: Thu, 25 Feb 2010 13:02:36 +0200
Message-ID: <1267095756.12391.6.camel@Nokia-N900-42-11>
Reply-To: <opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"Linux Kernel Network Developers" <netdev@vger.kernel.org>,
	"Linux Kernel Developers" <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: "Cong Wang" <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-ID: <1267095756.12391.5.camel@Nokia-N900-42-11>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I think one of them is enough, since we already chose commas, why
> do we need to add spaces? If you have some strong reason to add it,
> I have no objections.
>

It is just for simpler implementation. It is actually harder to restrict the separator to only commas insted of allowing both spaces and commas, because I rely on functions used for the integer vector handling. 

Maybe I should change those functions to be more generic and thus to allow more stricter input, but I am not sure if its worth it. Isn't a more permissive input format desirable?
