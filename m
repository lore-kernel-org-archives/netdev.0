From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]snmp6 64-bit counter support in proc.c
Date: Thu, 22 Jan 2004 17:43:19 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040122.174319.74739148.davem@redhat.com>
References: <OFB1A49B9E.7066A43F-ON87256E24.0005F5B5@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kumarkr@us.ibm.com, kuznet@ms2.inr.ac.ru, mashirle@us.ibm.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: xma@us.ibm.com
In-Reply-To: <OFB1A49B9E.7066A43F-ON87256E24.0005F5B5@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Shirley Ma <xma@us.ibm.com>
   Date: Thu, 22 Jan 2004 17:08:04 -0800
   
   Do you really care about this situation? It only happens as a race within
   one instruction in 4 billion. It will slow everytime if we do this way.

correctness > performance

If MRTG hits this case and my net usage graphs have weird spikes
in them as a result, can I assign the bugzilla entry to you? :-)
