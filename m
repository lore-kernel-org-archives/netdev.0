From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] SNMP_ADD_STATS
Date: Wed, 12 Jun 2002 15:58:04 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020612.155804.36818109.davem@redhat.com>
References: <20020612182348.GP1073@conectiva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: acme@conectiva.com.br
In-Reply-To: <20020612182348.GP1073@conectiva.com.br>
List-Id: netdev.vger.kernel.org

   From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
   Date: Wed, 12 Jun 2002 15:23:48 -0300
   
   So I propose that we have
   
   #define SNMP_ADD_STATS(mib, field, incr) ((mib)[2*smp_processor_id()+!in_softirq()].field += incr)
   
   and
   
   #define IP_ADD_STATS(field,incr) SNMP_ADD_STATS(ip_statistics, field, incr)
   
   Any objections?

No problem.
