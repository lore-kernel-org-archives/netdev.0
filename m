From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: vlan tagged packets and libpcap breakage
Date: Mon, 17 Dec 2012 12:08:50 +0100
Message-ID: <CAD6jFUT-yOOedjySHB9nGh4QdwtrGA3k1XQTjXP76-1xghVM6A@mail.gmail.com>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	<3246.1351717319@obiwan.sandelman.ca>
	<CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	<21992.1351723328@obiwan.sandelman.ca>
	<alpine.OSX.2.00.1212121205040.78903@animac.local>
	<50C9936B.2000201@redhat.com>
	<CAOxq_8PuMF2n80g30aXbPFQyo6UfsypZOHREjB36dnnp87nv=A@mail.gmail.com>
	<CAD6jFUTht82HOjGjDU7hFCEWyE3TOx_W4_j=SZK-DrcGfrio-A@mail.gmail.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B70EF@saturn3.aculab.com>
	<DE6D5B28-FA1E-4F04-9BDF-F6D35878776E@alum.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Richardson <mcr@sandelman.ca>, netdev@vger.kernel.org,
	tcpdump-workers@lists.tcpdump.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: Guy Harris <guy@alum.mit.edu>
Return-path: <tcpdump-workers-bounces@lists.tcpdump.org>
In-Reply-To: <DE6D5B28-FA1E-4F04-9BDF-F6D35878776E@alum.mit.edu>
List-Unsubscribe: <https://lists.sandelman.ca/mailman/options/tcpdump-workers>,
	<mailto:tcpdump-workers-request@lists.tcpdump.org?subject=unsubscribe>
List-Archive: <http://lists.sandelman.ca/pipermail/tcpdump-workers>
List-Post: <mailto:tcpdump-workers@lists.tcpdump.org>
List-Help: <mailto:tcpdump-workers-request@lists.tcpdump.org?subject=help>
List-Subscribe: <https://lists.sandelman.ca/mailman/listinfo/tcpdump-workers>,
	<mailto:tcpdump-workers-request@lists.tcpdump.org?subject=subscribe>
Sender: tcpdump-workers-bounces@lists.tcpdump.org
Errors-To: tcpdump-workers-bounces@lists.tcpdump.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 17, 2012 at 11:35 AM, Guy Harris <guy@alum.mit.edu> wrote:
> On Dec 17, 2012, at 1:50 AM, "David Laight" <David.Laight@ACULAB.COM> wrote:
>
>> How are you going to tell whether a feature is present in a non-Linux
>> kernel ?
>
> The Linux memory-mapped capture mechanism is not present in a non-Linux kernel, so all the libpcap work involved here would, if necessary on other platforms, have to be done differently on those platforms.  Those platforms would have to have their own mechanisms to indicate whether any changes to filter code, processing of VLAN tags supplied out of band, etc. would need to be done.
>
> The same would apply to other additional features of the Linux memory-mapped capture mechanism that require changes in libpcap.

Exactly.
_______________________________________________
tcpdump-workers mailing list
tcpdump-workers@lists.tcpdump.org
https://lists.sandelman.ca/mailman/listinfo/tcpdump-workers
