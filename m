From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFT 2/2] macb: kill PHY reset code
Date: Mon, 11 Apr 2016 21:39:02 +0300
Message-ID: <570BEF46.7060105@cogentembedded.com>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <2811962.eGX2i5RJbZ@wasted.cogentembedded.com>
 <20160411022802.GB4307@lunn.ch> <570BE1C5.70502@cogentembedded.com>
 <20160411181904.GB29709@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160411181904.GB29709@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 04/11/2016 09:19 PM, Andrew Lunn wrote:

>>> The code you are deleting would of ignored the flags in the gpio
>>> property, i.e. active low.
>>
>>     Hm, you're right -- I forgot about that... :-/
>>
>>> The new code in the previous patch does
>>> however take the flags into account. Did you check if there are any
>>> device trees which have flags, which were never used, but are now
>>> going to be used and thus break...
>>
>>     Checked this now and found out arch/arm/boot/dts/ar91-vinco.dts.
>> Looks like it needs to be fixed indeed...
>>
> And this is where it gets tricky. You are breaking backwards
> compatibility by now respecting the flag. An old DT blob is not going
> to work.

    Do we care that much about the DT blobs that are just *wrong*?

> You potentially need to add a new property and deprecate the old one.

    I would like to avoid that...

>      Andrew

MBR, Sergei
