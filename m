From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: Re: [e100] Page allocation failure warning(?) in
 2.6.36.3
Date: Mon, 10 Jan 2011 16:37:37 -0800
Message-ID: <F675EE07F28A0A4E933E5F9DD28672FB01197E098F@orsmsx508.amr.corp.intel.com>
References: <F675EE07F28A0A4E933E5F9DD28672FB01197E08E2@orsmsx508.amr.corp.intel.com>
	<688142.89079.qm@web121707.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chris Rankin <rankincj@yahoo.com>, "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <688142.89079.qm@web121707.mail.ne1.yahoo.com>
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

Chris,
The reason I asked you about bridge is because I have noticed "br0: port 1(eth1) entering learning state" in the dmesg log you sent.
I am trying to figure out exactly what sequence of commands you run that produce this message " br0: port 1(eth1) entering learning state" in log.
Also if you let me know output of 
#cat /etc/network/interface
#ifconfig -a

Thanks.


-Tushar

-----Original Message-----
From: Chris Rankin [mailto:rankincj@yahoo.com] 
Sent: Monday, January 10, 2011 3:42 PM
To: e1000-devel@lists.sourceforge.net; Dave, Tushar N
Cc: netdev@vger.kernel.org
Subject: RE: [E1000-devel] [e100] Page allocation failure warning(?) in 2.6.36.3

--- On Mon, 10/1/11, Dave, Tushar N <tushar.n.dave@intel.com> wrote:
> Does the issue appears only when you add a bridge?

Tushar,

I'm not sure what you mean by "add a bridge". I've been using this box ever since the late 1990s, and have had the 3 e100 port since the early 2000s, so I can't say that I "do" anything with it apart from use it. 

The PCI configuration remains as it always has, and the box get rebooted only to receive stable kernel updates. Looking back through old dmesg logs, it looks like this issue also happened in 2.6.33.6 too without me ever realising. Hence I am suspecting that this problem has been happening intermittently for ages...

Is there anything else I can tell you about this ropey old P200 MMX PC before Indiana Jones finds it and tries putting it in his museum ;-)?

Cheers,
Chris


      
------------------------------------------------------------------------------
Gaining the trust of online customers is vital for the success of any company
that requires sensitive data to be transmitted over the Web.   Learn how to 
best implement a security strategy that keeps consumers' information secure 
and instills the confidence they need to proceed with transactions.
http://p.sf.net/sfu/oracle-sfdevnl 
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
