From: Sachin Sant <sachinp@in.ibm.com>
Subject: -next Mar 22: s390 build failure (drivers/s390/net/qeth_l3)
Date: Mon, 22 Mar 2010 14:40:59 +0530
Message-ID: <4BA73423.6080101@in.ibm.com>
References: <20100322171937.d753bdba.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	ursula.braun@de.ibm.com, Stephen Hemminger <shemminger@vyatta.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>
To: linux-s390@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100322171937.d753bdba.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Todays next fails to build on a s390 box with

  CC [M]  drivers/s390/net/qeth_l3_main.o
drivers/s390/net/qeth_l3_main.c: In function 'qeth_l3_free_vlan_addresses6':
drivers/s390/net/qeth_l3_main.c:1931: error: incompatible types in assignment
drivers/s390/net/qeth_l3_main.c:1931: error: 'struct inet6_ifaddr' has no member named 'lst_next'
make[2]: *** [drivers/s390/net/qeth_l3_main.o] Error 1

commit c2e21293c054817c42eb5fa9c613d2ad51954136
(ipv6: convert addrconf list to hlist) 
converted lst_next member of inet6_ifaddr struct to a hlist.

Thanks
-Sachin


-- 

---------------------------------
Sachin Sant
IBM Linux Technology Center
India Systems and Technology Labs
Bangalore, India
---------------------------------
