From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: RE: RFC: NAPI packet weighting patch
Date: Fri, 3 Jun 2005 20:08:48 +0200
Message-ID: <17056.40112.39108.32685@robur.slu.se>
References: <468F3FDA28AA87429AD807992E22D07E0450BFE6@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <jdmason@us.ibm.com>,
        <shemminger@osdl.org>, <hadi@cyberus.ca>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>, <netdev@oss.sgi.com>,
        <Robert.Olsson@data.slu.se>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Ronciak, John" <john.ronciak@intel.com>
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E0450BFE6@orsmsx408>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ronciak, John writes:
 > > What more do you need other than checking the statistics counter?  The
 > > drop statistics (the ones we care about) are incremented in real time
 > > by the ->poll() code, so it's not like we have to trigger some
 > > asynchronous event to get a current version of the number.
 > > 
 > 
 > I think that there is some more confusion here.  I'm talking about
 > frames dropped by the Ethernet controller at the hardware level (no
 > descriptor available).  This for example is happening now with our
 > driver with the weight set to 64.  This is also what started us looking
 > into what was going on with the weight.  I don't see how the NAPI code
 > to dynamically adjust the weight could easily get the hardware stats
 > number to know if frames are being dropped or not.  Sorry if I caused
 > the confusion here.

 It's not obvious that weight is to blame for frames dropped. I would 
 look into RX ring size in relation to HW mitigation.
 And of course if you system is very loaded the RX softirq gives room
 for other jobs and frames get dropped

 Cheers.
 					--ro
 
