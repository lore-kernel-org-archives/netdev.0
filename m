From: "Bin Ren" <bin_ren@myrealbox.com>
Subject: the logic behind rt_hash_code()
Date: Thu, 15 Aug 2002 23:56:05 -0600
Sender: owner-netdev@oss.sgi.com
Message-ID: <1029477365.be039780bin_ren@myrealbox.com>
Reply-To: bin_ren@myrealbox.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, here I have a question:

When
we are trying to find out the IP routing info while sending a packet, that
time, first we try to find if there's any match in the routing Hash Bucket
by calling ip_route_output ( ) function. If not found, then we call
ip_rout_output_slow ( )
function which looks for the FIB table. Now in the first case where we
search in the rt_hash_buscket, we first find out a hash Number by calling
the function
rt_hash_code ( ). I don't understand the logic in finding out the hash
number. They are doing so many exoring, shifting operations to find the
hash Number. Does anyone know
the logic of finding the Hash function? Can U describe me that???

Thanks in advance.

Laudney Ren
