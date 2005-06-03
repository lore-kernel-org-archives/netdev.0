From: "Ronciak, John" <john.ronciak@intel.com>
Subject: RE: RFC: NAPI packet weighting patch
Date: Fri, 3 Jun 2005 10:40:47 -0700
Message-ID: <468F3FDA28AA87429AD807992E22D07E0450BFE6@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <jdmason@us.ibm.com>, <shemminger@osdl.org>, <hadi@cyberus.ca>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>, <netdev@oss.sgi.com>,
        <Robert.Olsson@data.slu.se>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> What more do you need other than checking the statistics counter?  The
> drop statistics (the ones we care about) are incremented in real time
> by the ->poll() code, so it's not like we have to trigger some
> asynchronous event to get a current version of the number.
> 

I think that there is some more confusion here.  I'm talking about
frames dropped by the Ethernet controller at the hardware level (no
descriptor available).  This for example is happening now with our
driver with the weight set to 64.  This is also what started us looking
into what was going on with the weight.  I don't see how the NAPI code
to dynamically adjust the weight could easily get the hardware stats
number to know if frames are being dropped or not.  Sorry if I caused
the confusion here.

Mitch is working on a response to Jamal's last mail trying to level set
what we are seeing and doing.

Cheers,
John
