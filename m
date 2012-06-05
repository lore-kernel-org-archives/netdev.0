From: Alessandro Rubini <rubini@gnudd.com>
Subject: Re: [PATCH RFC] c_can_pci: generic module for c_can on PCI
Date: Tue, 5 Jun 2012 15:30:13 +0200
Message-ID: <20120605133013.GA16108@mail.gnudd.com>
References: <4FCE07EE.40003@pengutronix.de>
  <D5ECB3C7A6F99444980976A8C6D896384FA5EC4DFC@EAPEX1MAIL1.st.com>
  <4FC135C6.5030206@grandegger.com> <1677842.Pq7naXsvrI@harkonnen>
  <D5ECB3C7A6F99444980976A8C6D896384FA5EC4B37@EAPEX1MAIL1.st.com>
  <3650428.HarNR9HfNF@harkonnen> <20120605131337.GA15432@mail.gnudd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhupesh.sharma@st.com, federico.vaga@gmail.com,
	alan@lxorguk.ukuu.org.uk, wg@grandegger.com,
	giancarlo.asnaghi@st.com, alan@linux.intel.com,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4FCE07EE.40003@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I personally like the "pci device sets up a platform device" idea.

Good. Than me or federico will submit a proposal. 
 
> My question is, is this considered being a good practise?

I don't think there are many pci bridges around, but platform drivers
exists just for that reason: to be instantiated when you know how the
wiring ("platform") details.  I.e., somebody registers the platform
device associated to the driver.

Sometimes the platform device is compiled in, sometimes it comes from
the device tree. I think it can come from PCI as well.

thanks
/alessandro, apologizing with Bhupesh Sharma for his tone in the previous mail
