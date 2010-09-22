From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: kvm networking todo wiki
Date: Wed, 22 Sep 2010 15:46:22 -0700
Message-ID: <4C9A873E.6010403@us.ibm.com>
References: <20100921161124.GC22845@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="------------060303030306080505060902"
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, lmr@redhat.com, "Xin,
	Xiaohui" <xiaohui.xin@intel.com>,
	Rusty Russell <rusty@rustcorp.com.au>, akong@redhat.com,
	kvm@vger.kernel.org, netdev@vger.kernel.org,
	Shirley Ma <mashirle@us.ibm.com>,
	David Stevens <dlstevens@us.ibm.com>, qemu-devel@nongnu.org,
	herbert@gondor.hengli.com.au, jdike@linux.intel.com, sri@linux.vnet.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <20100921161124.GC22845@redhat.com>
List-Unsubscribe: <http://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <http://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060303030306080505060902
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

  On Tue, 2010-09-21 at 18:11 +0200, Michael S. Tsirkin wrote:
> I've put up a wiki page with a kvm networking todo list,
> mainly to avoid effort duplication, but also in the hope
> to draw attention to what I think we should try addressing
> in KVM:
>
> http://www.linux-kvm.org/page/NetworkingTodo
>
> This page could cover all networking related activity in KVM,
> currently most info is related to virtio-net.
>
> Note: if there's no developer listed for an item,
> this just means I don't know of anyone actively working
> on an issue at the moment, not that no one intends to.
>
> I would appreciate it if others working on one of the items on this list
> would add their names so we can communicate better.  If others like this
> wiki page, please go ahead and add stuff you are working on if any.
>
> It would be especially nice to add autotest projects:
> there is just a short test matrix and a catch-all
> 'Cover test matrix with autotest', currently.
>
> Currently there are some links to Red Hat bugzilla entries,
> feel free to add links to other bugzillas.

Thanks for capturing these items. It is really useful.

Another item that is missing is
- support assigning SR-IOV VF to a guest via tap/macvtap

Currently, this requires
  - VF to be put in promiscuous mode when using a bridge/tap
  - add a new mac address to VF when using macvtap.

I don't think any of the VF drivers provide these capabilities
at this time.

-Sridhar


--------------060303030306080505060902
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by e6.ny.us.ibm.com id o8MMklt7016965

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3DUTF=
-8">
    <meta name=3D"GENERATOR" content=3D"GtkHTML/3.26.3">
  </head>
  <body bgcolor=3D"#ffffff" text=3D"#000000">
    On Tue, 2010-09-21 at 18:11 +0200, Michael S. Tsirkin wrote:
    <blockquote type=3D"CITE">
      <pre><!--+GtkHTML:<DATA class=3D"ClueFlow" key=3D"orig" value=3D"1"=
>-->I've put up a wiki page with a kvm networking todo list,
mainly to avoid effort duplication, but also in the hope
to draw attention to what I think we should try addressing
in KVM:

<a href=3D"http://www.linux-kvm.org/page/NetworkingTodo">http://www.linux=
-kvm.org/page/NetworkingTodo</a>

This page could cover all networking related activity in KVM,
currently most info is related to virtio-net.

Note: if there's no developer listed for an item,
this just means I don't know of anyone actively working
on an issue at the moment, not that no one intends to.

I would appreciate it if others working on one of the items on this list
would add their names so we can communicate better.  If others like this
wiki page, please go ahead and add stuff you are working on if any.

It would be especially nice to add autotest projects:
there is just a short test matrix and a catch-all
'Cover test matrix with autotest', currently.

Currently there are some links to Red Hat bugzilla entries,
feel free to add links to other bugzillas.
</pre>
    </blockquote>
    <!--+GtkHTML:<DATA class=3D"ClueFlow" key=3D"orig" value=3D"0">--><br=
>
    <!--+GtkHTML:<DATA class=3D"ClueFlow" key=3D"orig" value=3D"0">--><tt=
>Thanks
      for capturing these items. It is really useful.<br>
      <br>
      Another item that is missing is<br>
      - support assigning SR-IOV VF to a guest via tap/macvtap<br>
      <br>
      Currently, this requires <br>
      =C2=A0- VF to be put in promiscuous mode when using a bridge/tap<br=
>
      =C2=A0- add a new mac address to VF when using macvtap.<br>
      <br>
      I don't think any of the VF drivers provide these capabilities<br>
      at this time.<br>
    </tt>
    <pre><tt></tt>-Sridhar
</pre>
  </body>
</html>

--------------060303030306080505060902--
