From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: RFT: virtio_net: limit xmit polling
Date: Fri, 24 Jun 2011 05:50:33 -0700
Message-ID: <CA29D629.2C9B1%roprabhu@cisco.com>
References: <201106211023.24643.tahm@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4127046239959269658=="
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, habanero@linux.vnet.ibm.com,
        lguest@lists.ozlabs.org, Shirley Ma <xma@us.ibm.com>,
        kvm@vger.kernel.org, Carsten Otte <cotte@de.ibm.com>,
        linux-s390@vger.kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>,
        linux-kernel@vger.kernel.org,
        virtualization@lists.linux-foundation.org, steved@us.ibm.com,
        Christian Borntraeger <borntraeger@de.ibm.com>, netdev@vger.kernel.org,
        Martin Schwidefsky <schwidefsky@de.ibm.com>, linux390@de.ibm.com
To: Tom Lendacky <tahm@linux.vnet.ibm.com>,
        "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <201106211023.24643.tahm@linux.vnet.ibm.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Mime-version: 1.0
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

> This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

--===============4127046239959269658==
Content-type: multipart/alternative;
	boundary="B_3391739433_7656829"

> This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

--B_3391739433_7656829
Content-type: text/plain;
	charset="US-ASCII"
Content-transfer-encoding: 7bit

Michael,  

I am testing this too.
 I have finished one round of testing. But am running it again just to
confirm.
This time I will see if I can collect some exit stats too. Will post results
sometime this weekend.
I am just doing TCP_STREAM and TCP_MAERTS from guest to remote host.

Thanks,
Roopa


On 6/21/11 8:23 AM, "Tom Lendacky" <tahm@linux.vnet.ibm.com> wrote:

> On Sunday, June 19, 2011 05:27:00 AM Michael S. Tsirkin wrote:
>> > OK, different people seem to test different trees.  In the hope to get
>> > everyone on the same page, I created several variants of this patch so
>> > they can be compared. Whoever's interested, please check out the
>> > following, and tell me how these compare:
> 
> I'm in the process of testing these patches.  Base and v0 are complete
> and v1 is near complete with v2 to follow.  I'm testing with a variety
> of TCP_RR and TCP_STREAM/TCP_MAERTS tests involving local guest-to-guest
> tests and remote host-to-guest tests.  I'll post the results in the next
> day or two when the tests finish.
> 
> Thanks,
> Tom
> 
>> >
>> > kernel:
>> >
>> > git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git
>> >
>> > virtio-net-limit-xmit-polling/base - this is net-next baseline to test
>> > against virtio-net-limit-xmit-polling/v0 - fixes checks on out of capacity
>> > virtio-net-limit-xmit-polling/v1 - previous revision of the patch
>> >               this does xmit,free,xmit,2*free,free
>> > virtio-net-limit-xmit-polling/v2 - new revision of the patch
>> >               this does free,xmit,2*free,free
>> >
>> > There's also this on top:
>> > virtio-net-limit-xmit-polling/v3 -> don't delay avail index update
>> > I don't think it's important to test this one, yet
>> >
>> > Userspace to use: event index work is not yet merged upstream
>> > so the revision to use is still this:
>> > git://git.kernel.org/pub/scm/linux/kernel/git/mst/qemu-kvm.git
>> > virtio-net-event-idx-v3
> 


--B_3391739433_7656829
Content-type: text/html;
	charset="US-ASCII"
Content-transfer-encoding: quoted-printable

<HTML>
<HEAD>
<TITLE>Re: RFT: virtio_net: limit xmit polling</TITLE>
</HEAD>
<BODY>
<FONT FACE=3D"Calibri, Verdana, Helvetica, Arial"><SPAN STYLE=3D'font-size:11pt=
'>Michael, &nbsp;<BR>
<BR>
I am testing this too.<BR>
&nbsp;I have finished one round of testing. But am running it again just to=
 confirm.<BR>
This time I will see if I can collect some exit stats too. Will post result=
s sometime this weekend. <BR>
I am just doing TCP_STREAM and TCP_MAERTS from guest to remote host.<BR>
<BR>
Thanks,<BR>
Roopa<BR>
<BR>
<BR>
On 6/21/11 8:23 AM, &quot;Tom Lendacky&quot; &lt;<a href=3D"tahm@linux.vnet.i=
bm.com">tahm@linux.vnet.ibm.com</a>&gt; wrote:<BR>
<BR>
</SPAN></FONT><BLOCKQUOTE><FONT FACE=3D"Calibri, Verdana, Helvetica, Arial"><=
SPAN STYLE=3D'font-size:11pt'>On Sunday, June 19, 2011 05:27:00 AM Michael S. =
Tsirkin wrote:<BR>
&gt; OK, different people seem to test different trees. &nbsp;In the hope t=
o get<BR>
&gt; everyone on the same page, I created several variants of this patch so=
<BR>
&gt; they can be compared. Whoever's interested, please check out the<BR>
&gt; following, and tell me how these compare:<BR>
<BR>
I'm in the process of testing these patches. &nbsp;Base and v0 are complete=
<BR>
and v1 is near complete with v2 to follow. &nbsp;I'm testing with a variety=
<BR>
of TCP_RR and TCP_STREAM/TCP_MAERTS tests involving local guest-to-guest<BR=
>
tests and remote host-to-guest tests. &nbsp;I'll post the results in the ne=
xt<BR>
day or two when the tests finish.<BR>
<BR>
Thanks,<BR>
Tom<BR>
<BR>
&gt;<BR>
&gt; kernel:<BR>
&gt;<BR>
&gt; git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git<BR>
&gt;<BR>
&gt; virtio-net-limit-xmit-polling/base - this is net-next baseline to test=
<BR>
&gt; against virtio-net-limit-xmit-polling/v0 - fixes checks on out of capa=
city<BR>
&gt; virtio-net-limit-xmit-polling/v1 - previous revision of the patch<BR>
&gt; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;this does xmit,free,xmit,2*free,free<BR>
&gt; virtio-net-limit-xmit-polling/v2 - new revision of the patch<BR>
&gt; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;this does free,xmit,2*free,free<BR>
&gt;<BR>
&gt; There's also this on top:<BR>
&gt; virtio-net-limit-xmit-polling/v3 -&gt; don't delay avail index update<=
BR>
&gt; I don't think it's important to test this one, yet<BR>
&gt;<BR>
&gt; Userspace to use: event index work is not yet merged upstream<BR>
&gt; so the revision to use is still this:<BR>
&gt; git://git.kernel.org/pub/scm/linux/kernel/git/mst/qemu-kvm.git<BR>
&gt; virtio-net-event-idx-v3<BR>
<BR>
</SPAN></FONT></BLOCKQUOTE>
</BODY>
</HTML>


--B_3391739433_7656829--


--===============4127046239959269658==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linux-foundation.org/mailman/listinfo/virtualization
--===============4127046239959269658==--
