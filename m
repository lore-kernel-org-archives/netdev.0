From: "AnilKumar, Chimata" <anilkumar@ti.com>
Subject: RE: [PATCH RFC] c_can_pci: generic module for c_can on PCI
Date: Tue, 5 Jun 2012 15:12:36 +0000
Message-ID: <331ABD5ECB02734CA317220B2BBEABC13E9CB18A@DBDE01.ent.ti.com>
References: <4FCE07EE.40003@pengutronix.de>
  <D5ECB3C7A6F99444980976A8C6D896384FA5EC4DFC@EAPEX1MAIL1.st.com>
  <4FC135C6.5030206@grandegger.com> <1677842.Pq7naXsvrI@harkonnen>
  <D5ECB3C7A6F99444980976A8C6D896384FA5EC4B37@EAPEX1MAIL1.st.com>
  <3650428.HarNR9HfNF@harkonnen> <20120605131337.GA15432@mail.gnudd.com>
 <20120605133013.GA16108@mail.gnudd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "bhupesh.sharma@st.com" <bhupesh.sharma@st.com>,
	"federico.vaga@gmail.com" <federico.vaga@gmail.com>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"giancarlo.asnaghi@st.com" <giancarlo.asnaghi@st.com>,
	"alan@linux.intel.com" <alan@linux.intel.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alessandro Rubini <rubini@gnudd.com>,
	"mkl@pengutronix.de" <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20120605133013.GA16108@mail.gnudd.com>
Content-Language: en-US
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alessandro/Federico,

On Tue, Jun 05, 2012 at 19:00:13, Alessandro Rubini wrote:
> > I personally like the "pci device sets up a platform device" idea.
> 
> Good. Than me or federico will submit a proposal. 
>  

I am late to the discussion, is there any specific reason to maintain a
separate platform file (c_can_pci.c). I think 90% of the code is copied
from c_can_paltform.c, code changes will be less if you merge to existing
c_can platform driver. You can look at D_CAN integration to C_CAN driver.

[1] https://gitorious.org/linux-can/linux-can-next

Regards
AnilKumar