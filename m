From: Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
Subject: Re: [PATCH] net: Linn Ethernet Packet Sniffer driver
Date: Mon, 26 Jan 2015 11:05:31 +0000
Message-ID: <54C61F7B.1000407@linn.co.uk>
References: <1422007621-13567-1-git-send-email-stathis.voukelatos@linn.co.uk> <1817503.588aons8oi@radagast>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stathis Voukelatos <stathisv70-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1817503.588aons8oi@radagast>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On 23/01/15 18:12, James Hogan wrote:
>> diff --git a/drivers/net/pkt-sniffer/Kconfig 
>> b/drivers/net/pkt-sniffer/Kconfig
>> new file mode 100644
>> index 0000000..26b4f98
>> --- /dev/null
>> +++ b/drivers/net/pkt-sniffer/Kconfig
>> @@ -0,0 +1,23 @@
>> +menuconfig PKT_SNIFFER
>> +    tristate "Linn packet sniffer support"
> Should the kconfig symbol have linn in the name, or should the prompt
> not have lin in the name?

No it should not actually, as this option enables the core (framework) 
driver.
Anybody could add a backend using the framework. Will change the text.

>> +
>> +config PKT_SNIFFER_ETHER
>> +    tristate "Ethernet packet sniffer"
>> +    depends on MIPS
> worth adding || COMPILE_TEST to get compile coverage on x86 allmodconfig
> builds, or does it have hard dependencies on the MIPS arch?
>

No hard dependencies on MIPS arch. Will change as you suggest.
Will implement your other recommendations too in the next version
of the patchset.

Thank you,
Stathis

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
