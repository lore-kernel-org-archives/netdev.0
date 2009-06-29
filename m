From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Mon, 29 Jun 2009 09:57:25 +0200
Message-ID: <4A4873E5.2000402@itcare.pl>
References: <19012.37515.146191.198843@robur.slu.se>	<20090627192057.GA5041@ami.dom.local>	<20090627205123.GA5265@ami.dom.local> <19015.20442.620760.399214@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Robert Olsson <robert@robur.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:48131 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751230AbZF2H50 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 03:57:26 -0400
In-Reply-To: <19015.20442.620760.399214@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Olsson pisze:
> When testing please monitor size of root node and and aver depth
>
> Cheers
> 				--ro
>   
Some fib_triestats - kernel.2.6.29.5 with first Jarek patch.

Dump every 10sec:

Mon Jun 29 11:54:31 2009
Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     2.28
        Max depth:      7
        Leaves:         276978
        Prefixes:       290448
        Internal nodes: 66813
          1: 34703  2: 13944  3: 9921  4: 4807  5: 2273  6: 1158  7: 5  
9: 1  18: 1
        Pointers: 691606
Null ptrs: 347816
Total size: 18403  kB

Counters:
---------
gets = 390981859
backtracks = 5332465
semantic match passed = 390452936
semantic match miss = 30198
null node hit= 375522207
skipped node resize = 0

Local:
        Aver depth:     3.75
        Max depth:      5
        Leaves:         12
        Prefixes:       13
        Internal nodes: 10
          1: 9  2: 1
        Pointers: 22
Null ptrs: 1
Total size: 2  kB

Counters:
---------
gets = 391017445
backtracks = 121012874
semantic match passed = 37565
semantic match miss = 0
null node hit= 261583
skipped node resize = 0

Mon Jun 29 11:54:41 2009
Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     2.28
        Max depth:      7
        Leaves:         276976
        Prefixes:       290446
        Internal nodes: 66813
          1: 34703  2: 13944  3: 9921  4: 4807  5: 2273  6: 1158  7: 5  
9: 1  18: 1
        Pointers: 691606
Null ptrs: 347818
Total size: 18403  kB

Counters:
---------
gets = 391061852
backtracks = 5334173
semantic match passed = 390532664
semantic match miss = 30199
null node hit= 375595706
skipped node resize = 0

Local:
        Aver depth:     3.75
        Max depth:      5
        Leaves:         12
        Prefixes:       13
        Internal nodes: 10
          1: 9  2: 1
        Pointers: 22
Null ptrs: 1
Total size: 2  kB

Counters:
---------
gets = 391097445
backtracks = 121039213
semantic match passed = 37570
semantic match miss = 0
null node hit= 261589
skipped node resize = 0

Mon Jun 29 11:54:51 2009
Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     2.28
        Max depth:      7
        Leaves:         276978
        Prefixes:       290448
        Internal nodes: 66813
          1: 34703  2: 13944  3: 9921  4: 4807  5: 2273  6: 1158  7: 5  
9: 1  18: 1
        Pointers: 691606
Null ptrs: 347816
Total size: 18403  kB

Counters:
---------
gets = 391177325
backtracks = 5336127
semantic match passed = 390647917
semantic match miss = 30208
null node hit= 375699713
skipped node resize = 0

Local:
        Aver depth:     3.75
        Max depth:      5
        Leaves:         12
        Prefixes:       13
        Internal nodes: 10
          1: 9  2: 1
        Pointers: 22
Null ptrs: 1
Total size: 2  kB

Counters:
---------
gets = 391212932
backtracks = 121075919
semantic match passed = 37586
semantic match miss = 0
null node hit= 261701
skipped node resize = 0

Mon Jun 29 11:55:01 2009
Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     2.28
        Max depth:      7
        Leaves:         276978
        Prefixes:       290448
        Internal nodes: 66813
          1: 34703  2: 13944  3: 9921  4: 4807  5: 2273  6: 1158  7: 5  
9: 1  18: 1
        Pointers: 691606
Null ptrs: 347816
Total size: 18403  kB

Counters:
---------
gets = 391254016
backtracks = 5337816
semantic match passed = 390724361
semantic match miss = 30214
null node hit= 375768712
skipped node resize = 0

Local:
        Aver depth:     3.75
        Max depth:      5
        Leaves:         12
        Prefixes:       13
        Internal nodes: 10
          1: 9  2: 1
        Pointers: 22
Null ptrs: 1
Total size: 2  kB

Counters:
---------
gets = 391289631
backtracks = 121101285
semantic match passed = 37598
semantic match miss = 0
null node hit= 261707
skipped node resize = 0

Mon Jun 29 11:55:11 2009
Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     2.28
        Max depth:      7
        Leaves:         276976
        Prefixes:       290445
        Internal nodes: 66812
          1: 34702  2: 13944  3: 9921  4: 4807  5: 2273  6: 1158  7: 5  
9: 1  18: 1
        Pointers: 691604
Null ptrs: 347817
Total size: 18402  kB

Counters:
---------
gets = 391317389
backtracks = 5339175
semantic match passed = 390787523
semantic match miss = 30215
null node hit= 375827612
skipped node resize = 0

Local:
        Aver depth:     3.75
        Max depth:      5
        Leaves:         12
        Prefixes:       13
        Internal nodes: 10
          1: 9  2: 1
        Pointers: 22
Null ptrs: 1
Total size: 2  kB

Counters:
---------
gets = 391353001
backtracks = 121122087
semantic match passed = 37599
semantic match miss = 0
null node hit= 261709
skipped node resize = 0

Mon Jun 29 11:55:21 2009
Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     2.28
        Max depth:      7
        Leaves:         276981
        Prefixes:       290451
        Internal nodes: 66813
          1: 34704  2: 13943  3: 9921  4: 4807  5: 2273  6: 1158  7: 5  
9: 1  18: 1
        Pointers: 691604
Null ptrs: 347811
Total size: 18403  kB

Counters:
---------
gets = 391434307
backtracks = 5340855
semantic match passed = 390904256
semantic match miss = 30225
null node hit= 375931780
skipped node resize = 0

Local:
        Aver depth:     3.75
        Max depth:      5
        Leaves:         12
        Prefixes:       13
        Internal nodes: 10
          1: 9  2: 1
        Pointers: 22
Null ptrs: 1
Total size: 2  kB

Counters:
---------
gets = 391469942
backtracks = 121157220
semantic match passed = 37619
semantic match miss = 0
null node hit= 261753
skipped node resize = 0

Mon Jun 29 11:55:31 2009
Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     2.28
        Max depth:      7
        Leaves:         276981
        Prefixes:       290451
        Internal nodes: 66813
          1: 34704  2: 13943  3: 9921  4: 4807  5: 2273  6: 1158  7: 5  
9: 1  18: 1
        Pointers: 691604
Null ptrs: 347811
Total size: 18403  kB

Counters:
---------
gets = 391519852
backtracks = 5342208
semantic match passed = 390989658
semantic match miss = 30234
null node hit= 376010537
skipped node resize = 0

Local:
        Aver depth:     3.75
        Max depth:      5
        Leaves:         12
        Prefixes:       13
        Internal nodes: 10
          1: 9  2: 1
        Pointers: 22
Null ptrs: 1
Total size: 2  kB

Counters:
---------
gets = 391555492
backtracks = 121181992
semantic match passed = 37625
semantic match miss = 0
null node hit= 261762
skipped node resize = 0

Mon Jun 29 11:55:42 2009
Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     2.28
        Max depth:      7
        Leaves:         276978
        Prefixes:       290447
        Internal nodes: 66812
          1: 34703  2: 13943  3: 9921  4: 4807  5: 2273  6: 1158  7: 5  
9: 1  18: 1
        Pointers: 691602
Null ptrs: 347813
Total size: 18403  kB

Counters:
---------
gets = 391589032
backtracks = 5343757
semantic match passed = 391058601
semantic match miss = 30237
null node hit= 376075389
skipped node resize = 0

Local:
        Aver depth:     3.75
        Max depth:      5
        Leaves:         12
        Prefixes:       13
        Internal nodes: 10
          1: 9  2: 1
        Pointers: 22
Null ptrs: 1
Total size: 2  kB

Counters:
---------
gets = 391624673
backtracks = 121202115
semantic match passed = 37628
semantic match miss = 0
null node hit= 261763
skipped node resize = 0

Mon Jun 29 11:55:52 2009
Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     2.28
        Max depth:      7
        Leaves:         276985
        Prefixes:       290455
        Internal nodes: 66814
          1: 34704  2: 13944  3: 9921  4: 4807  5: 2273  6: 1158  7: 5  
9: 1  18: 1
        Pointers: 691608
Null ptrs: 347810
Total size: 18403  kB

Counters:
---------
gets = 391723925
backtracks = 5345934
semantic match passed = 391193292
semantic match miss = 30242
null node hit= 376195655
skipped node resize = 0

Local:
        Aver depth:     3.75
        Max depth:      5
        Leaves:         12
        Prefixes:       13
        Internal nodes: 10
          1: 9  2: 1
        Pointers: 22
Null ptrs: 1
Total size: 2  kB

Counters:
---------
gets = 391759578
backtracks = 121241080
semantic match passed = 37640
semantic match miss = 0
null node hit= 261804
skipped node resize = 0

Mon Jun 29 11:56:02 2009
Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     2.28
        Max depth:      7
        Leaves:         276985
        Prefixes:       290455
        Internal nodes: 66814
          1: 34704  2: 13944  3: 9921  4: 4807  5: 2273  6: 1158  7: 5  
9: 1  18: 1
        Pointers: 691608
Null ptrs: 347810
Total size: 18403  kB

Counters:
---------
gets = 391811219
backtracks = 5347635
semantic match passed = 391280357
semantic match miss = 30250
null node hit= 376276182
skipped node resize = 0

Local:
        Aver depth:     3.75
        Max depth:      5
        Leaves:         12
        Prefixes:       13
        Internal nodes: 10
          1: 9  2: 1
        Pointers: 22
Null ptrs: 1
Total size: 2  kB

Counters:
---------
gets = 391846880
backtracks = 121265316
semantic match passed = 37648
semantic match miss = 0
null node hit= 261813
skipped node resize = 0


>      	       	       	    	 
>
> Jarek Poplawski writes:
>  > On Sat, Jun 27, 2009 at 09:20:57PM +0200, Jarek Poplawski wrote:
>  > ...
>  > > Then these settable thresholds might be more useful here than memory
>  > > fixes, but here is some idea to try handle this automatically within
>  > > some limits. The patch below increases inflate_threshold_root (only)
>  > > up to ~50% of its initial value if needed, and should be able to go
>  > > back sometimes.
>  > > 
>  > > Pawel and Jorge, could you try this? (It applies to 2.6.29 too, with
>  > > some offsets.)
>  > 
>  > A tiny adjustment in the last if...
>  > 
>  > Jarek P.
>  > --- (take 2)
>  > 
>  >  net/ipv4/fib_trie.c |   23 ++++++++++++++++-------
>  >  1 files changed, 16 insertions(+), 7 deletions(-)
>  > 
>  > diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
>  > index 012cf5a..1dc1bb4 100644
>  > --- a/net/ipv4/fib_trie.c
>  > +++ b/net/ipv4/fib_trie.c
>  > @@ -318,6 +318,7 @@ static const int halve_threshold = 25;
>  >  static const int inflate_threshold = 50;
>  >  static const int halve_threshold_root = 8;
>  >  static const int inflate_threshold_root = 15;
>  > +static int inflate_threshold_root_fix;
>  >  
>  >  
>  >  static void __alias_free_mem(struct rcu_head *head)
>  > @@ -602,7 +603,8 @@ static struct node *resize(struct trie *t, struct tnode *tn)
>  >  	/* Keep root node larger  */
>  >  
>  >  	if (!tn->parent)
>  > -		inflate_threshold_use = inflate_threshold_root;
>  > +		inflate_threshold_use = inflate_threshold_root +
>  > +					inflate_threshold_root_fix;
>  >  	else
>  >  		inflate_threshold_use = inflate_threshold;
>  >  
>  > @@ -626,15 +628,22 @@ static struct node *resize(struct trie *t, struct tnode *tn)
>  >  	}
>  >  
>  >  	if (max_resize < 0) {
>  > -		if (!tn->parent)
>  > -			pr_warning("Fix inflate_threshold_root."
>  > -				   " Now=%d size=%d bits\n",
>  > -				   inflate_threshold_root, tn->bits);
>  > -		else
>  > +		if (!tn->parent) {
>  > +			if (inflate_threshold_root_fix * 2 <
>  > +			    inflate_threshold_root)
>  > +				inflate_threshold_root_fix++;
>  > +			else
>  > +				pr_warning("Fix inflate_threshold_root."
>  > +					   " Now=%d size=%d bits fix=%d\n",
>  > +					   inflate_threshold_root, tn->bits,
>  > +					   inflate_threshold_root_fix);
>  > +		} else {
>  >  			pr_warning("Fix inflate_threshold."
>  >  				   " Now=%d size=%d bits\n",
>  >  				   inflate_threshold, tn->bits);
>  > -	}
>  > +		}
>  > +	} else if (max_resize > 4 && !tn->parent && inflate_threshold_root_fix)
>  > +		inflate_threshold_root_fix--;
>  >  
>  >  	check_tnode(tn);
>  >  
>  > --
>  > To unsubscribe from this list: send the line "unsubscribe netdev" in
>  > the body of a message to majordomo@vger.kernel.org
>  > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>   

