From: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Subject: Re: [PATCH RFC 2/3] dt:net:stmmac: Add support to dwmac version 3.610
 and 3.710
Date: Tue, 02 Jul 2013 10:04:33 +0200
Message-ID: <51D28991.3050704@st.com>
References: <1372678962-12959-1-git-send-email-srinivas.kandagatla@st.com>
 <1372679034-13139-1-git-send-email-srinivas.kandagatla@st.com>
 <51D1BA52.3030201@st.com> <51D27658.1060806@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: srinivas.kandagatla-qxv4g6HH51o@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <51D27658.1060806-qxv4g6HH51o@public.gmane.org>
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

On 7/2/2013 8:42 AM, Srinivas KANDAGATLA wrote:
> Are you happy with the setting pmt based on compatible string or do you
> think passing pmt as another property to device tree makes more sense?

I prefer to pass pmt as another property but indeed this is not a big
problem because all the new chips have the HW cap. register to fix
at run-time the driver capability.

This field, as others, was really useful on old mac generations where
sometime the PMT was synthesized, sometime not.

The code should be safe enough because if, for example,
we have a new GMAC but w/o the extended module for PMT, so at probing
time the driver will fix all by looking at the HW cap register and
it will be never able to do WoL.

ciao
peppe
