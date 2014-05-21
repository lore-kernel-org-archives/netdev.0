From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH RESEND net-next 1/9] Documentation: devicetree: add old
 and deprecated 'fixed-link'
Date: Thu, 22 May 2014 01:48:31 +0400
Message-ID: <537D1F2F.6050100@cogentembedded.com>
References: <1400708331-18088-1-git-send-email-f.fainelli@gmail.com> <1400708331-18088-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Pantelis Antoniou <pantelis.antoniou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Vitaly Bordug <vbordug-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>,
	Li Yang <leoli-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Aida Mynzhasova <aida.mynzhasova-Fmhy8gsqeTEvJsYlp49lxw@public.gmane.org>,
	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"open list:OPEN FIRMWARE AND..." <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:LINUX FOR POWERPC..." <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1400708331-18088-2-git-send-email-f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 05/22/2014 01:38 AM, Florian Fainelli wrote:

> Update the fixed-link Device Tree binding documentation to contain
> information about the old and deprecated 5-digit 'fixed-link' property.

> Signed-off-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>   Documentation/devicetree/bindings/net/fixed-link.txt | 12 ++++++++++++
>   1 file changed, 12 insertions(+)

> diff --git a/Documentation/devicetree/bindings/net/fixed-link.txt b/Documentation/devicetree/bindings/net/fixed-link.txt
> index e956de1be935..34a991eb213f 100644
> --- a/Documentation/devicetree/bindings/net/fixed-link.txt
> +++ b/Documentation/devicetree/bindings/net/fixed-link.txt
> @@ -18,6 +18,18 @@ properties:
>   * 'asym-pause' (boolean, optional), to indicate that asym_pause should
>     be enabled.
>
> +Old, deprecated 'fixed-link' binding:
> +
> +* A 'fixed-link' property in the EThernet MAC node, with 5 cells, of the

    s/EThernet/Ethernet/

> +  form <a b c d e> with the following accepted values:
> +  - a: emulated phy id, choose any but but unique to the all specified

    s/phy id/PHY ID/

> +    fixed-links, from 0 to 31
> +  - b: duplex configuration: 0 for half duplex, 1 for full duplex
> +  - c: link speed in Mbits/sec, accepted values are: 10, 100 and 1000
> +  - d: pause configuration: 0 for no pause, 1 for pause
> +  - e: asymetric pause configuration: 0 for no asymetric pause, 1 for asymetric

    Asymmetric.

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
