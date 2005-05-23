From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: Re: Why /sys/class/net/*/features is read-only?
Date: Mon, 23 May 2005 23:49:57 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0505232346310.17855@webhosting.rdsbv.ro>
References: <Pine.LNX.4.62.0505201346420.29305@webhosting.rdsbv.ro>
 <20050523092827.7883af33@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050523092827.7883af33@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 23 May 2005, Stephen Hemminger wrote:

> On Mon, 23 May 2005 10:46:50 +0300 (EEST)
> "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro> wrote:
>
>> Hello!
>>
>> Why features file is read-only. If an admin want to force some attributes,
>> we can let them, right?
>>
>
> Leave it read-only because the hardware may not want to allow them on that flavor and so it would
> have to be device specific.

You are clear right for hardware devices, but for software ones (bridge 
for example) it makes sense. Anyway, only admin can change them.

If you have a bridge with 5 net cards and 4 supports SG, some people 
may want to force SG on the bridge.

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
