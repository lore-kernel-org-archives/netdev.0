From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH 0/12] remove sk_protinfo series
Date: Fri, 21 Jan 2005 01:18:47 -0200
Message-ID: <41F07497.4020109@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Networking Team <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

	This series addresses Christoph and Jean concerns about the overhead
caused by private slab caches in every family, by making sk_alloc use kmalloc
if no slab cache is used, and as a transitional mechanism the zero_it
semantic is maintained, that is, if slab is NULL and zero_it is 1, use the
generic "slab" (sk_cachep) cache.

	Now only the ham radio protocols (AX25, NETROM and ROSE) and
net/wanrouter uses sk_protinfo to store an private area directly, and
bluetooth uses it as a second level for proto info while using a
private slab cache for the first level of proto info.

	This series has atm and pppox in addition to the set of families
covered in the first series.

	Available at:

bk://kernel.bkbits.net/acme/connection_sock-2.6

Best Regards,

- Arnaldo
