From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] Re: [PATCH 02/11] IB/ipoib: Notify the world before
	doing unregister
Date: Tue, 18 Sep 2007 10:42:57 -0700
Message-ID: <ada3axblvj2.fsf@cisco.com>
References: <11898132301664-git-send-email-fubar@us.ibm.com>
	<11898132322950-git-send-email-fubar@us.ibm.com>
	<1189813234208-git-send-email-fubar@us.ibm.com>
	<adatzptkjyk.fsf@cisco.com> <18593.1190071438@death>
	<adaps0glve4.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, davem@davemloft.net,
	general@lists.openfabrics.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adaps0glve4.fsf@cisco.com> (Roland Dreier's message of "Mon,
	17 Sep 2007 16:33:39 -0700")
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

 > Maybe this new notification function should be in net/core/dev.c
 > instead of exporting call_netdevice_notifiers()?

Or actually, does it work to add the call to the notifiers directly in
unregister_netdev() so that device drivers don't have to worry about it?

(And is the existing patch missing a call to notifiers in ipoib_vlan_delete()?)

 - R.
