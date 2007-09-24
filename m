From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [ofa-general] Re: [PATCHES] TX batching
Date: Mon, 24 Sep 2007 15:52:58 -0700
Message-ID: <46F83FCA.9000406@intel.com>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>	
	<20070916.161748.48388692.davem@davemloft.net>	
	<1189988958.4230.55.camel@localhost>
	<1190569987.4256.52.camel@localhost>	 <46F6AE18.7080708@garzik.org>
	<1190574713.5030.4.camel@localhost>	 <46F6C059.6000600@intel.com>
	<1190582448.4240.2.camel@localhost>	 <46F76087.8030109@intel.com>
	<1190673505.4264.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, Robert.Olsson@data.slu.se, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, peter.p.waskiewicz.jr@intel.com,
	shemminger@linux-foundation.org, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, Jeff Garzik <jeff@garzik.org>,
	rdreier@cisco.com, mcarlson@broadcom.com,
	general@lists.openfabrics.org, sri@us.ibm.com, jagana@us.ibm.com,
	mchan@broadcom.com, "Kok, Auke" <auke-jan.h.kok@intel.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	tgraf@suug.ch, kaber@trash.net
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1190673505.4264.11.camel@localhost>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2007-24-09 at 00:00 -0700, Kok, Auke wrote:
> 
>> that's bad to begin with :) - please send those separately so I can fasttrack them
>> into e1000e and e1000 where applicable.
> 
> Ive been CCing you ;-> Most of the changes are readability and
> reusability with the batching.
> 
>> But yes, I'm very inclined to merge more features into e1000e than e1000. I intend
>> to put multiqueue support into e1000e, as *all* of the hardware that it will
>> support has multiple queues. Putting in any other performance feature like tx
>> batching would absolutely be interesting.
> 
> I looked at the e1000e and it is very close to e1000 so i should be able
> to move the changes easily. Most importantly, can i kill LLTX?
> For tx batching, we have to wait to see how Dave wants to move forward;
> i will have the patches but it is not something you need to push until
> we see where that is going.

hmm, I though I already removed that, but now I see some remnants from that.

By all means, please send a separate patch for that!

Auke
