From: Zhiwei Yu <zhiwei@celestix.com>
Subject: IPv6 over VLAN
Date: 16 Apr 2003 19:03:11 +0800
Sender: owner-users@ipv6.org
Message-ID: <1050490991.3749.125.camel@summerpalace>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: users@ipv6.org
Return-path: <owner-users@ipv6.org>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

I am using Redhat 2.4.18-5 kernel rpm with VLAN 1.5 patch.  It's easy to
assign global IPv6 addresses to VLAN interface, and generate local link
IPv6 address automatically.  But can not ping6 any IPv6 client on the
same VLAN.  I can capture the ipv6 neigh sol packets on the VLAN
interface of destination machine, but the destination machine never
reply as the way it did on the physical interface. And I am sure the
VLAN setting is correct, because I can ping IPv4 address of destination
machine.

Here is the reply from linux vlan maintainer. 

>------- Additional Comments From greearb@candelatech.com  2003-04-15
>10:45 -------
>This could also be a bug in the IPv6 code, as VLAN should be agnostic
to
>the type of traffic running over the top of it.  Please submit your
report
>to netdev@oss.sgi.com as well.

And I think the comment is correct, VLAN is just a tagging, and I was
successfully implement OSPF and RIP over VLAN.  Because I am a newbies
in IPv6, hope you guys can help me out.

Thanks in advance
-- 
Zhiwei Yu
R & D Engineer 
Celestix Network Pte. Ltd

=====================================================================
No, I don't use perl--I consider it an unreadable write-only language.
                                            -- W. Richard Stevens


---------------------------------------------------------------------
The IPv6 Users Mailing List
Unsubscribe by sending "unsubscribe users" to majordomo@ipv6.org
