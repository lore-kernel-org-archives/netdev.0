From: "David S. Miller" <davem@redhat.com>
Subject: Re: Casting (struct rtable*) to (struct dst_entry*)
Date: Wed, 19 Mar 2003 20:59:12 -0800 (PST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030319.205912.131928327.davem@redhat.com>
References: <200303192355.02509.nalkunda@cse.msu.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: nalkunda@cse.msu.edu
In-Reply-To: <200303192355.02509.nalkunda@cse.msu.edu>
List-Id: netdev.vger.kernel.org

   From: N N Ashok <nalkunda@cse.msu.edu>
   Date: Wed, 19 Mar 2003 23:55:02 -0500
   
   I am unable to understand how a rtable structure casted to dst_entry will give 
   a correct pointer to the input() function. I looked at the fields in rtable 
   and dst_entry, the fields in the structures are cannot be lined up (the 
   fourth field in rtable is not the same type as the fourth field in 
   dst_entry). 

"struct rtable" starts with a "struct dst_entry"
