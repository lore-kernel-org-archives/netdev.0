From: Ben Greear <greearb@candelatech.com>
Subject: Re: rfc-editor@rfc-editor.org: RFC 3549 on Linux Netlink as an IP
 Services Protocol
Date: Thu, 03 Jul 2003 11:00:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F046F56.1080808@candelatech.com>
References: <12785.1057250058@marajade.sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>, hadi@znyx.com,
   hormuzd.m.khosravi@intel.com, ak@suse.de, kuznet@ms2.inr.ac.ru,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
In-Reply-To: <12785.1057250058@marajade.sandelman.ottawa.on.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please make the 'table-id' field to be at least
16 bits.  Now that we have VLANs and other types of virtual
interfaces, it would be nice to be able to have a routing table
for each interface, for example.  640k was not enough for everyone,
and ~250 routing tables isn't either :)


 From section 3.1.1:

    Table ID: 8 bits
    Table identifier.  Up to 255 route tables are supported.
                  RT_TABLE_UNSPEC    An unspecified routing table.
                  RT_TABLE_DEFAULT   The default table.
                  RT_TABLE_MAIN      The main table.
                  RT_TABLE_LOCAL     The local table.

                  The user may assign arbitrary values between
                  RT_TABLE_UNSPEC(0) and RT_TABLE_DEFAULT(253).

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
