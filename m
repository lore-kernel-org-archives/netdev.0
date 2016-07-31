From: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>
Subject: RE: [PATCH v5 5/8] thunderbolt: Networking state machine
Date: Sun, 31 Jul 2016 11:58:41 +0000
Message-ID: <E607265CB020454880711A6F96C05A039710884A@hasmsx108.ger.corp.intel.com>
References: <1469693721-5641-1-git-send-email-amir.jer.levy@intel.com>
 <1469693721-5641-6-git-send-email-amir.jer.levy@intel.com>
 <20160728113550.GA1701@wunner.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "andreas.noever@gmail.com" <andreas.noever@gmail.com>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"bhelgaas@google.com" <bhelgaas@google.com>,
	"corbet@lwn.net" <corbet@lwn.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	thunderbolt-linux <thunderbolt-linux@intel.com>,
	"Westerberg, Mika" <mika.westerberg@intel.com>,
	"Winkler, Tomas" <tomas.winkler@intel.com>
To: Lukas Wunner <lukas@wunner.de>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20160728113550.GA1701@wunner.de>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 28 2016, 02:35 PM, Lukas Wunner wrote:
> On Thu, Jul 28, 2016 at 11:15:18AM +0300, Amir Levy wrote:
> > +				nhi_ctxt->net_devices[
> > +					port_num].medium_sts =
> 
> Looks like a carriage return slipped in here.

Will be fixed.

> 
> In patch [4/8], I've found it a bit puzzling that FW->SW responses and
> FW->SW notifications are defined in icm_nhi.c, whereas SW->FW commands
> are defined in net.h. It would perhaps be more logical to have them all in the
> header file. The FW->SW responses and SW->FW commands are almost
> identical, there are odd spelling differences (CONNEXION vs.
> CONNECTION).

Will move them to the header and will change to CONNECTION.

> 
> It would probably be good to explain the PDF acronym somewhere.

Will explain in the enum.

> 
> I've skimmed over all patches in the series, too superficial to provide a
> Reviewed-by, it's just too much code to review thoroughly and I also lack the
> hardware to test it, but broadly this LGTM.

Thank you for the review.
