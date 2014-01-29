From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 0/2] DT: net: davinci_emac: couple more properties actually
 optional
Date: Thu, 30 Jan 2014 01:42:28 +0300
Message-ID: <52E983D4.4070405@cogentembedded.com>
References: <201401280245.35745.sergei.shtylyov@cogentembedded.com> <20140128.234315.2164810932256158473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, rob@landley.net, devicetree@vger.kernel.org,
	linux-doc@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20140128.234315.2164810932256158473.davem@davemloft.net>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 01/29/2014 10:43 AM, David Miller wrote:

>>     Though described as required, couple more properties in the DaVinci EMAC
>> binding are actually optional, as the driver will happily function without them.
>> The patchset is against DaveM's 'net.git' tree this time.

>> [1/2] DT: net: davinci_emac: "ti,davinci-rmii-en" property is actually optional
>> [2/2] DT: net: davinci_emac: "ti,davinci-no-bd-ram" property is actually optional

> Series applied with the "has/have" thing fixed.

> Thanks.

    Thank you!
    Unfortunately, this driver presents a bad example of DT bindings overall 
(caused in its turn by a misuse of the platform data for the EMAC type 
differing instead of the platform device IDs).

WBR, Sergei

