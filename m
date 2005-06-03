From: "Ronciak, John" <john.ronciak@intel.com>
Subject: RE: RFC: NAPI packet weighting patch
Date: Fri, 3 Jun 2005 11:19:02 -0700
Message-ID: <468F3FDA28AA87429AD807992E22D07E0450BFE8@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, <jdmason@us.ibm.com>,
        <shemminger@osdl.org>, <hadi@cyberus.ca>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>, <netdev@oss.sgi.com>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Robert Olsson" <Robert.Olsson@data.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>  It's not obvious that weight is to blame for frames dropped. I would 
>  look into RX ring size in relation to HW mitigation.
>  And of course if you system is very loaded the RX softirq gives room
>  for other jobs and frames get dropped
> 
With the same system (fairly high end with nothing major running on it)
we got rid of the dropped frames by just reducing the weight for 64.  So
the weight did have something to do with the dropped frames.  Maybe
other factors as well, but in static tests like this it sure looks like
the 64 value is wrong is some cases.


Cheers,
John
