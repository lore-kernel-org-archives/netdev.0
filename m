From: "Ronciak, John" <john.ronciak@intel.com>
Subject: RE: RFC: NAPI packet weighting patch
Date: Tue, 7 Jun 2005 09:23:32 -0700
Message-ID: <468F3FDA28AA87429AD807992E22D07E0450C01F@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "David S. Miller" <davem@davemloft.net>, <mchan@broadcom.com>,
        <buytenh@wantstofly.org>, <jdmason@us.ibm.com>, <netdev@oss.sgi.com>,
        <Robert.Olsson@data.slu.se>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: <hadi@cyberus.ca>, "Stephen Hemminger" <shemminger@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>> 
> To the intel folks: shouldnt someone be investigating why this is so?

This is why we started all of this.  We have data that is showing this
issue where our over all performance is best in class and yet we can
make it better by changing things like the weight value.

There also seems to be some misconceptions about changing the weight
value.  It actually improves the performance of other drivers as well.
Not as much as it improves the e1000 performance but it does seem to
help others as well.  We (Intel) have to be careful talking about
competitors performance so we just refer to them as competitors in these
threads.  So it is not just e1000 who benefits from the lower weight
values.  One thing it is doing for e1000 right now is that it is
stopping the e1000 from dropping frames which is part of why it's
helping the e1000 more (I think).

I agree that we need to bottom out on this and it's why we are
dedicating the time and resources to this effort.  We also appreciate
all the effort to help resolve this as well.  This should result in a
better performing 2.6 stack and drivers.  The new TSO code is a big step
in that direction as well.

Cheers,
John
