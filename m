From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFT] BIC TCP delayed ack compensation
Date: Wed, 23 Feb 2005 11:36:41 -0800
Message-ID: <20050223113641.3f9404ef@dxpl.pdx.osdl.net>
References: <052Q0TU11@server5.heliogroup.fr>
	<200502231830.j1NIUC2T019474@uni07mr.unity.ncsu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "'Hubert Tonneau'" <hubert.tonneau@fullpliant.org>,
        "'cliff white'"
 <cliffw@osdl.org>,
        "'Alexey Kuznetsov'" <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>,
        "'David S. Miller'" <davem@davemloft.net>
To: "Injong Rhee" <rhee@eos.ncsu.edu>
In-Reply-To: <200502231830.j1NIUC2T019474@uni07mr.unity.ncsu.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

An interesting test would be to repeat the slow case: 2.6.10-ac11 over 100Mbps

With first TCP Reno (old default).
	sysctl -w net.ipv4.tcp_bic=0
then TCP Westwood.
	sysctl -w net.ipv4.tcp_bic=0
	sysctl -w net.ipv4.tcp_westwood=1
