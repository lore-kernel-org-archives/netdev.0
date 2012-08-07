From: Timur Tabi <timur-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Subject: Re: [PATCH] netdev/phy: skip disabled mdio-mux nodes
Date: Tue, 7 Aug 2012 12:04:00 -0500
Message-ID: <50214A80.4020305@freescale.com>
References: <1344358266-5450-1-git-send-email-timur@freescale.com>
 <5021496D.8070200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 "devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org"
 <devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>, Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: David Daney <ddaney.cavm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <5021496D.8070200-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

David Daney wrote:
> Although this will get the job done, I don't think it is the cleanest 
> approach.
> 
> Would it be better to create a new iterator 
> (for_each_available_child_of_node perhaps) that skips the unavailable 
> nodes?  This seems like a general problem that is not restricted to mdio 
> multiplexers.

You're probably right, but this is how it's normally done.  If you're
going to scan child nodes manually, you have to skip disabled nodes.

If someone else wants to implement for_each_available_child_of_node(), I'm
all for it, but such a patch would not be merged until 3.7.  I was hoping
to have my patch applied to 3.6, since it fixes a real bug.

-- 
Timur Tabi
Linux kernel developer at Freescale
