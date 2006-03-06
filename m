From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: RFC: move SDP from AF_INET_SDP to IPPROTO_SDP
Date: Mon, 6 Mar 2006 12:32:50 -0800
Message-ID: <54AD0F12E08D1541B826BE97C98F99F12FBF39@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@mellanox.co.il>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751964AbWCFUdF@vger.kernel.org>
Content-class: urn:content-classes:message
To: "David Stevens" <dlstevens@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: David Stevens [mailto:dlstevens@us.ibm.com] 
> Sent: Monday, March 06, 2006 12:32 PM
> To: Caitlin Bestler
> Cc: Linux Kernel Mailing List; Michael S. Tsirkin; 
> netdev@vger.kernel.org
> Subject: RE: RFC: move SDP from AF_INET_SDP to IPPROTO_SDP
> 
> IPPROTO_* should match the protocol field on the wire, which 
> I gather isn't different. And I'm assuming there is no 
> standard API defined already...
> 

SDP uses the existing standard sockets API.
That was the intent in its design, and it is
the sole justification for its use. If you are
not using the existing sockets API then your
application would be *far* better off coding
directly to RDMA.

The wire protocol *is* different, it uses RDMA.
There is some justification for the application
knowing this, albeit slight ones. For example 
you need to know if the peer supports SDP and
it might effect how intermediate firewalls
need to be configured.
