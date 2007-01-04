From: "Roland Dreier" <rdreier@cisco.com>
Subject: Re: one vs. two drivers for an iWARP-capable
 Ethernet NIC
Date: Thu, 04 Jan 2007 13:45:59 -0800
Message-ID: <adabqle4ga0.fsf@cisco.com>
References: <78C9135A3D2ECE4B8162EBDCE82CAD77010FB436@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Jeff Garzik" <jgarzik@pobox.com>,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "Leonid Grossman" <Leonid.Grossman@neterion.com>
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD77010FB436@nekter> (Leonid
 Grossman's message of "Thu, 28 Dec 2006 16:31:13 -0500")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

 > Jeff/Roland/all,
 > What is the preferred submission driver model for an iWARP-capable
 > Ethernet NIC - two separate drivers (Ethernet and OpenFabrics) that
 > interact with each other, or a single driver that supports both
 > OpenFabrics and Ethernet interfaces?

Let's not use the term "OpenFabrics interface."  Let's just call the
two interfaces RDMA and ethernet (or L2 NIC if you like).

Anyway my preference would be for the cleanest possible driver.  If
your driver is not naturally divided into two separate parts then it's
fine to have a unified driver.  We already have examples of both:
amso1100 is unified and the Chelsio T3 driver is split.

 - R.
