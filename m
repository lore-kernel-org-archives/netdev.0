From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 2/2] openvswitch: Use zerocopy if
 applicable when performing the upcall
Date: Mon, 27 May 2013 10:28:05 +0900
Message-ID: <CAEP_g=944Wq982rDSC0hrqUBu8Sf6MCtQN0NhgyU5FDr9UB3ww@mail.gmail.com>
References: <cover.1369406826.git.tgraf@suug.ch>
	<064a09fffe48540b66a3ee503860ed9e8a1eb5f1.1369406826.git.tgraf@suug.ch>
	<CAEP_g=87CuiS92YtCZ1V1ME05qq0jGWD9p1WgKZ2jaaG1AWS7w@mail.gmail.com>
	<1369421900.3301.431.camel@edumazet-glaptop>
	<CAEP_g=898=iOWV15Y_bcjvS9sGSfDQSP1zQLNkffoXB5imdU7g@mail.gmail.com>
	<1369432621.3301.445.camel@edumazet-glaptop>
	<CAEP_g=9Yqcf6_cpPYNAbiQUGjQa46PEz6gQdKAopiNNUDRhGYA@mail.gmail.com>
	<20130525070222.GB30252@casper.infradead.org>
	<1369492772.3301.468.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0731809570=="
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1369492772.3301.468.camel@edumazet-glaptop>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============0731809570==
Content-Type: multipart/alternative; boundary=089e011839847b38de04dda90fb8

--089e011839847b38de04dda90fb8
Content-Type: text/plain; charset=UTF-8

On Saturday, May 25, 2013, Eric Dumazet wrote:

> On Sat, 2013-05-25 at 08:02 +0100, Thomas Graf wrote:
>
> > I ran TCP_CRR to verify the SYN/ACK use case and I did not
> > observe a difference. If you have any specific test in mind
> > I will be glad to run that before posting the 2nd revision.
>
> I guess you should test with rx checksum disabled as well, Jesse seemed
> to be concerned about that.


 I was actually thinking about the transmit side - rx checksum verification
doesn't matter much here since the result will get thrown away. However, if
the packet is CHECKSUM_PARTIAL then the checksum will have to get filled in
first and that's the code path that is a little different now.

--089e011839847b38de04dda90fb8
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Saturday, May 25, 2013, Eric Dumazet  wrote:<br><blockquote class=3D"gma=
il_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-lef=
t:1ex">On Sat, 2013-05-25 at 08:02 +0100, Thomas Graf wrote:<br>
<br>
&gt; I ran TCP_CRR to verify the SYN/ACK use case and I did not<br>
&gt; observe a difference. If you have any specific test in mind<br>
&gt; I will be glad to run that before posting the 2nd revision.<br>
<br>
I guess you should test with rx checksum disabled as well, Jesse seemed<br>
to be concerned about that.</blockquote><blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"></bl=
ockquote><div><br></div><div>=C2=A0I was actually thinking about the transm=
it side - rx checksum verification doesn&#39;t matter much here since the r=
esult will get thrown away. However, if the packet is CHECKSUM_PARTIAL then=
 the checksum will have to get filled in first and that&#39;s the code path=
 that is a little different now.<span></span></div>

--089e011839847b38de04dda90fb8--

--===============0731809570==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0731809570==--
