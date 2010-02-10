From: Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Subject: Re: phy address in the device tree, vs auto probing
Date: Wed, 10 Feb 2010 12:28:02 -0600
Message-ID: <4B72FAB2.5000804@freescale.com>
References: <4dfe033d-c308-45e0-9c7e-9fc60c6cad8f@SG2EHSMHS013.ehs.local>
	<fa686aa41002100843o7a1d4160q8fb01768ad48dcf4@mail.gmail.com>
	<7d35ae9a-9ac0-46e6-8817-15315e0dcc07@SG2EHSMHS004.ehs.local>
	<fa686aa41002101014s43682e3cra55854b82a40bb5f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	devicetree-discuss <devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Andy Fleming <afleming-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <fa686aa41002101014s43682e3cra55854b82a40bb5f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Grant Likely wrote:
>> 1. What if we just don't specific a phy address with a reg property which would specify to auto probe it and find the phy as illustrated below?
>>
>>
>>                Ethernet_MAC: ethernet@81000000 {
>>                        #address-cells = <1>;
>>                        #size-cells = <1>;
>>                        phy-handle = <&phy0>;
>>                        mdio {
>>                                #address-cells = <1>;
>>                                #size-cells = <0>;
>>                                phy0: phy@7 {
>>                                } ;
>>                        } ;
>>
>> 2. Or a special value (-1 or something not 0 - 31) in the phy address that specifies to auto probe as illustrated below.
>>                                phy0: phy@7 {
>>                                        reg = <-1>;
>>                                } ;
> 
> I don't like abusing the reg property in this way.  I wonder if a new
> empty property would be a better way to indicate this.  Maybe
> "phy-probe-address;"?  It would also be important to specify in the
> binding that only one phy node is allowed when phy-probe-address is
> used.
> 
> Also, without a known reg the 'phy@7' name is inaccurate.  Drop the @7.
> 
> Scott, Andy: any thoughts?

I'm not fond of the -1.  I'd prefer the explicit phy-probe-address property, 
though I don't mind too much using the absence of reg.

-Scott
