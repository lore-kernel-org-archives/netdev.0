From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v2a RESEND 2/2] of_mdio: Allow the DT to specify the phy
 ID and avoid autoprobing
Date: Wed, 19 Mar 2014 16:14:04 -0600
Message-ID: <20140319221404.GA1154@obsidianresearch.com>
References: <1394658311-17769-1-git-send-email-jgunthorpe@obsidianresearch.com>
 <1394658311-17769-2-git-send-email-jgunthorpe@obsidianresearch.com>
 <CAL_Jsq+qdbiwXErkZv1zZ9rphYY9NP6zHmmjw313tMvGeSTODg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Rob Herring <robherring2@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAL_Jsq+qdbiwXErkZv1zZ9rphYY9NP6zHmmjw313tMvGeSTODg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 12, 2014 at 04:35:54PM -0500, Rob Herring wrote:

> > Florian, do you know what path to mainline a this patch should take?
> 
> Via David's net tree.

Thanks

> > +       cp = of_get_property(device, "compatible", &cplen);
> > +       if (cp == NULL)
> > +               return -EINVAL;
> > +       while (cplen > 0) {
> 
> This can all be:
> 
>   of_property_for_each_string(device, "compatible", prop, cp)

Done

On Thu, Mar 13, 2014 at 01:46:18AM +0300, Sergei Shtylyov wrote:
>    The preferred multi-line comment style is:
> 
> /*
>  * bla
>  * bla
>  */
> 

Sergei, the entire file use the 'net' multi-line commenting style, and
I have maintined that consistency with the new code.

v3 on its way.

Regards,
Jason
