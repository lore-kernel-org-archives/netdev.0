From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: Re: register_dev
Date: Mon, 28 Mar 2005 16:11:06 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0503281610530.25430@webhosting.rdsbv.ro>
References: <Pine.LNX.4.62.0503281451090.25430@webhosting.rdsbv.ro>
 <20050328122356.GX3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050328122356.GX3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 28 Mar 2005, Thomas Graf wrote:

> * Catalin(ux aka Dino) BOIE <Pine.LNX.4.62.0503281451090.25430@webhosting.rdsbv.ro> 2005-03-28 14:56
>> I do a register_netdev inside a _init function of a home made qdisc.
>> 2. the module is not loaded and I let tc trigger module loading
>> 	tc blocks on modprobe
>> How I can resolve this problem?
>
> Port the fix done for classifiers and actions to sch_api.c, see comments
> around request_module in cls_api.c

Thanks, Thomas!
I prepare a patch.

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
