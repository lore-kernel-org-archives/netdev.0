From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Patch 2.5.43] IpInDelivers, IpInDiscards
Date: Thu, 17 Oct 2002 16:43:26 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021017.164326.60506862.davem@redhat.com>
References: <Pine.LNX.4.44.0210171640190.3745-100000@w-nivedita.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: niv@us.ibm.com
In-Reply-To: <Pine.LNX.4.44.0210171640190.3745-100000@w-nivedita.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Nivedita Singhvi <niv@us.ibm.com>
   Date: Thu, 17 Oct 2002 16:47:58 -0700 (PDT)

   "The number of input IP datagrams for which no
    problems were encountered to prevent their continued
    processing, but which were discarded (e.g., for lack
    of buffer space). Note that this counter does not 
    include any datagrams discarded while awaiting re-assembly."
   
   However, I dont really object to it being a catchall
   for IP discards..
   
No, you are right.  We should match mib specs here.

I will take care of this myself, no need to repatch :)

Thanks a lot for your work, I'll post what I end up applying
to my tree.
