From: David Daney <ddaney.cavm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v6 0/3] netdev/of/phy: MDIO bus multiplexer support.
Date: Thu, 24 May 2012 12:19:53 -0700
Message-ID: <4FBE89D9.2090307@gmail.com>
References: <1336007799-31016-1-git-send-email-ddaney.cavm@gmail.com>
 <CAOZdJXWVCu+aNxcQRkcSSDsWWxnn8B9X5Y6=8oVgFwJ9SZTTGQ@mail.gmail.com>
 <4FB6C728.3090507@gmail.com> <4FB6C886.3050105@freescale.com>
 <4FB6CBF1.40300@gmail.com> <4FBE7DD8.509@freescale.com>
 <4FBE82F2.6080100@gmail.com> <4FBE8605.2020507@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org"
 <devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
 "linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
To: Timur Tabi <b04825-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <4FBE8605.2020507-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/24/2012 12:03 PM, Timur Tabi wrote:
> David Daney wrote:
>
>> Well, the MDIO bus must have an associated device tree node.
>>
>> For my OCTEON code, the MDIO bus device is created as a result of the
>> call to of_platform_bus_probe(), which takes care of filling in all the
>> device tree nodes of the devices it finds and creates.
>
> Ok, let me give you some background.  We actually already have MDIO muxing
> code in-house, but it's different from yours.  So now I'm rewriting it to
> use your design instead.
>
> So our current code looks for "virtual MDIO nodes", and we call
> mdiobus_alloc() and then of_mdiobus_register().  I think this is what I'm
> missing now.
>
> I just don't know what to do next.

You will have to debug it and find out why the device match is failing, 
then fix it.

David Daney
