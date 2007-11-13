From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel
	when promiscuous mode
Date: Tue, 13 Nov 2007 10:21:57 +0900
Message-ID: <b25c3fa70711121721o32bcab0fldf64ff0434a44a3c@mail.gmail.com>
References: <20071112231516.GA15227@1wt.eu>
	<20071112.151923.77768525.davem@davemloft.net>
	<20071112233257.GA15524@1wt.eu>
	<20071112.154046.117031917.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, kaber@trash.net, cfriesen@nortel.com,
	w@1wt.eu
To: "David Miller" <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20071112.154046.117031917.davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

2007/11/13, David Miller <davem@davemloft.net>:
> From: Willy Tarreau <w@1wt.eu>
> Date: Tue, 13 Nov 2007 00:32:57 +0100
>
> > At least, being able to disable the feature at module load time
> > would be acceptable. Many people who often need to sniff on decent
> > machines would always keep it disabled.
>
> I'm willing to accept the feature, in whatever form, as long
> as the performance issue is dealt with properly.

I agree with disabling the hw acceleration feature by manually would
be a non-negative solution.
IMO implementation in the ethtool seems better than module param.
As like Auke mentioned.
If you guys confirm it, I'll try it.

Thanks.
Joonwoo

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
