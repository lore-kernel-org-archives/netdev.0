From: Bjorn Andersson <bjorn@kryo.se>
Subject: Re: [PATCH 4/4] dt: binding: Add Qualcomm wcn36xx WiFi binding
Date: Tue, 29 Dec 2015 11:03:57 -0800
Message-ID: <20151229190357.GJ16437@tuxbot>
References: <1451266467-15377-1-git-send-email-bjorn.andersson@sonymobile.com>
 <1451266467-15377-5-git-send-email-bjorn.andersson@sonymobile.com>
 <20151229183440.GC12450@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kalle Valo <kvalo@codeaurora.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>, devicetree@vger.kernel.org,
	fengwei.yin@linaro.org, linux-arm-msm@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, wcn36xx@lists.infradead.org
To: Rob Herring <robh@kernel.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151229183440.GC12450@rob-hp-laptop>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue 29 Dec 10:34 PST 2015, Rob Herring wrote:

> On Sun, Dec 27, 2015 at 05:34:27PM -0800, Bjorn Andersson wrote:
> > Add binding representing the Qualcomm wcn3620/60/80 WiFi block.
> > Signed-off-by: Bjorn Andersson <bjorn.andersson@sonymobile.com>
> > ---
> >  .../bindings/net/wireless/qcom,wcn36xx-wifi.txt    | 76 ++++++++++++++++++++++
> >  1 file changed, 76 insertions(+)
> >  create mode 100644 Documentation/devicetree/bindings/net/wireless/qcom,wcn36xx-wifi.txt
> > 
> > diff --git a/Documentation/devicetree/bindings/net/wireless/qcom,wcn36xx-wifi.txt b/Documentation/devicetree/bindings/net/wireless/qcom,wcn36xx-wifi.txt
> > new file mode 100644
> > index 000000000000..7b314b9f30af
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/wireless/qcom,wcn36xx-wifi.txt
> > @@ -0,0 +1,76 @@
> > +Qualcomm WCN36xx WiFi Binding
> > +
> > +This binding describes the Qualcomm WCN36xx WiFi hardware. The hardware block
> > +is part of the Qualcomm WCNSS core, a WiFi/BT/FM combo chip, found in a variety
> > +of Qualcomm platforms.
> 
> Are BT/FM functions completely separate? If so, separate bindings are 
> okay. If not, then we need to describe the full chip.
> 

It's three different hardware blocks (WiFi, BT and FM-radio) with shared
RF-hardware and an ARM core for control logic.

There seems to be some control commands going towards the BT part that
controls coexistence properties of the RF-hardware, but other than that
I see it as logically separate blocks.


So I think it's fine to model this as separate pieces in DT.

Regards,
Bjorn
