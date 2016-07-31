From: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>
Subject: RE: [PATCH v5 4/8] thunderbolt: Communication with the ICM
 (firmware)
Date: Sun, 31 Jul 2016 12:07:28 +0000
Message-ID: <E607265CB020454880711A6F96C05A03971088C6@hasmsx108.ger.corp.intel.com>
References: <1469693721-5641-1-git-send-email-amir.jer.levy@intel.com>
	<1469693721-5641-5-git-send-email-amir.jer.levy@intel.com>
 <20160729140326.1fae0ced@xeon-e3>
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
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20160729140326.1fae0ced@xeon-e3>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 30 2016, 12:03 AM, Stephen Hemminger wrote:
> On Thu, 28 Jul 2016 11:15:17 +0300
> Amir Levy <amir.jer.levy@intel.com> wrote:
> 
> > +int nhi_send_message(struct tbt_nhi_ctxt *nhi_ctxt, enum pdf_value
> pdf,
> > +		     u32 msg_len, const u8 *msg, bool ignore_icm_resp) {
> 
> Why not make msg a void * and not have to do so many casts?

I couldn't agree more.
