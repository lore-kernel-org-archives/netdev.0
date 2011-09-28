From: Denis Radovanovic <Denis.Radovanovic@riverbed.com>
Subject: 82574 DMA Burst Mode Enablement
Date: Wed, 28 Sep 2011 18:39:54 +0000
Message-ID: <30751F5D655350478D3821069A3CF1F29D618D@365EXCH-MBX-P5.nbttech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0113002802385226747=="
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Prasanna Panchamukhi <Prasanna.Panchamukhi@riverbed.com>
To: "bruce.w.allan@intel.com" <bruce.w.allan@intel.com>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============0113002802385226747==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_30751F5D655350478D3821069A3CF1F29D618D365EXCHMBXP5nbtte_"

--_000_30751F5D655350478D3821069A3CF1F29D618D365EXCHMBXP5nbtte_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi,

We are currently testing small packet performance on 82574, comparing it to=
 82571. Initial pktgen measurements have shown a significant difference in =
performance that is the most visible when running bidirectional traffic wit=
h 256 byte packets.

Looking at the e1000e driver, we noticed that flag FLAG2_DMA_BURST is enabl=
ed for 82571 and 82572 but it is not enabled for 82574. After enabling the =
flag, the 82574 performance significantly improved, approaching the one on =
82571.

Is there a reason that this flag is not enabled for 82574?

Thank you,
Denis Radovanovic

--_000_30751F5D655350478D3821069A3CF1F29D618D365EXCHMBXP5nbtte_--


--===============0113002802385226747==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
All the data continuously generated in your IT infrastructure contains a
definitive record of customers, application performance, security
threats, fraudulent activity and more. Splunk takes this data and makes
sense of it. Business sense. IT sense. Common sense.
http://p.sf.net/sfu/splunk-d2dcopy1
--===============0113002802385226747==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============0113002802385226747==--
