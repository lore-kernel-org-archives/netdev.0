From: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>
Subject: RE: [PATCH v5 6/8] thunderbolt: Networking transmit and receive
Date: Mon, 1 Aug 2016 04:30:50 +0000
Message-ID: <E607265CB020454880711A6F96C05A039710FBC6@hasmsx107.ger.corp.intel.com>
References: <1469693721-5641-7-git-send-email-amir.jer.levy@intel.com>
	<20160729140741.18ca3e35@xeon-e3>
	<E607265CB020454880711A6F96C05A039710868B@hasmsx108.ger.corp.intel.com>
 <20160731.114513.2022660088754330528.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
	"andreas.noever@gmail.com" <andreas.noever@gmail.com>,
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
To: David Miller <davem@davemloft.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20160731.114513.2022660088754330528.davem@davemloft.net>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 31 2016, 09:45 PM, David Miller wrote:
> From: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>
> Date: Sun, 31 Jul 2016 10:15:52 +0000
> 
> > The network stack thinks it is Ethernet, it might not accept Runt
> > frames, so the driver pads the frame in receive.
> 
> The network stack doesn't care about this at all.  It's wasted effort on your
> part.

Great, I'll remove this code.
