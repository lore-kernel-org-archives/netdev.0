From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Mon, 16 Sep 2002 12:52:11 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020916.125211.82482173.davem@redhat.com>
References: <20020913.150439.27187393.davem@redhat.com>
	<Pine.LNX.4.44.0209160805360.7184-100000@gp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, tcw@tempest.prismnet.com, netdev@oss.sgi.com,
   pfeather@cs.unm.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, todd-lkml@osogrande.com
In-Reply-To: <Pine.LNX.4.44.0209160805360.7184-100000@gp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: todd-lkml@osogrande.com
   Date: Mon, 16 Sep 2002 08:16:47 -0600 (MDT)

   are there any standards in progress to support this.

Your question makes no sense, it is a hardware optimization
of an existing standard.  The chip merely is told what flows
exist and it concatenates TCP data from consequetive packets
for that flow if they arrive in sequence.
   
   who is working on this architecture for receives?

Once cards with the feature exist, probably Alexey and myself
will work on it.

Basically, who ever isn't busy with something else once the technology
appears.
   
   is there a beginning implementation yet of zerocopy receives

No.
   
Franks a lot,
David S. Miller
davem@redhat.com
