From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH 1/1] NUMA aware scheduling per cpu vhost thread
Date: Fri, 23 Mar 2012 17:45:40 -0600
Message-ID: <4F6D0B24.1010300@gmail.com>
References: <1332460136.7730.19.camel@oc3660625478.ibm.com> <1332461790.7730.21.camel@oc3660625478.ibm.com> <1510318.F8gXLSD366@tomlt1.ibmoffice.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shirley Ma <mashirle@us.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Thomas Lendacky <tahm@linux.vnet.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1510318.F8gXLSD366@tomlt1.ibmoffice.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/23/12 12:32 PM, Thomas Lendacky wrote:
> Quick description of the tests:
>    TCP_RR and UDP_RR using 256 byte request/response size in 1, 10, 30
>    and 60 instances
>    TCP_STREAM and TCP_MAERTS using 256, 1K, 4K and 16K message sizes
>    and 1 and 4 instances
>
>    Remote host to VM using 1, 4, 12 and 24 VMs (2 vCPUs) with the tests
>    running between an external host and each VM.
>
>    Local VM to VM using 2, 4, 12 and 24 VMs (2 vCPUs) with the tests
>    running between VM pairs on the same host (no TCP_MAERTS done in
>    this situation).
>
> For TCP_RR and UDP_RR tests I report the transaction rate as the
> score and the transaction rate / KVMhost CPU% as the efficiency.
>
> For TCP_STREAM and TCP_MAERTS tests I report the throughput in Mbps
> as the score and the throughput / KVMhost CPU% as the efficiency.
Would you mind sharing the netperf commands you are running and an 
example of the math done to arrive at the summaries presented?

David
