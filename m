From: Oskar Andreasson <blueflux@koffein.net>
Subject: [PATCH] Documentation fixes (was: Re: [RFC] Badly documented sysctl?)
Date: Mon, 4 Nov 2002 21:28:34 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0211042122060.31688-300000@laptop1.agatha>
References: <Pine.GSO.4.30.0211040833300.25806-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463810815-1330789550-1036441714=:31688"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <Pine.GSO.4.30.0211040833300.25806-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---1463810815-1330789550-1036441714=:31688
Content-Type: TEXT/PLAIN; charset=US-ASCII

Hi Jamal,

I have attached two patches for linux/Documentation/filesystems/proc.txt. 
One is for 2.5.45 kernels, and the other is for 2.4.19 kernels. I actually 
don't think there is a need for two patches, but I thought I would go with 
the safe side. 

This is a first time patch for me, so please forgive me if there's 
anything wrong with the format etc.

Let me know if there is any problems with the patches.

On Mon, 4 Nov 2002, jamal wrote:

> 
> You are correct. So fix the doc.
> 
> cheers,
> jamal
> 
> 
> On Fri, 1 Nov 2002, Oskar Andreasson wrote:
> 
> > Hi,
> >
> > I just started checking out the /proc/sys/net/ipv4/route/error_cost and
> > error_burst sysctl's. According to
> > linux/Documentation/filesystems/proc.txt:
> >
> > ----
> >
> > error_burst and error_cost
> > --------------------------
> >
> > These parameters are used to limit the warning messages written to the
> > kernel log from the routing code.  The higher the error_cost factor is,
> > the fewer messages will be written. Error_burst controls when messages
> > will be dropped. The default settings limit warning messages to one every
> > five seconds.
> >
> > ----
> >
> > I just spent some time reading the source code in question, and if I am
> > not totally off base... this is totally wrong? I am currently checking
> > linux/net/ipv4/route.c, and if I am right, it limits how many
> > ICMP_DEST_UNREACH we are sending to a specific host, and _possibly_ it
> > will also printk() in the ip_rt_send_redirect() function. I don't know for
> > sure, but I _think_ the default settings will limit ICMP_DEST_UNREACH
> > sending in ip_error() to 5 per second...
> >
> > If anyone would shed some light on this, I would be tremenduously happy!
> >
> > ----
> > Oskar Andreasson
> > http://www.frozentux.net
> > mailto:blueflux@koffein.net
> >
> >
> 
> 
> 

-- 
----
Oskar Andreasson
http://www.frozentux.net
http://iptables-tutorial.frozentux.net
http://ipsysctl-tutorial.frozentux.net
mailto:blueflux@koffein.net

---1463810815-1330789550-1036441714=:31688
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="2.4.19.docs.proc.txt.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0211042128340.31688@laptop1.agatha>
Content-Description: 
Content-Disposition: attachment; filename="2.4.19.docs.proc.txt.diff"

ZGlmZiAtdXIgbGludXgtMi40LjE5L0RvY3VtZW50YXRpb24vZmlsZXN5c3Rl
bXMvcHJvYy50eHQgbGludXgtMi40LjE5Lm5ldy9Eb2N1bWVudGF0aW9uL2Zp
bGVzeXN0ZW1zL3Byb2MudHh0DQotLS0gbGludXgtMi40LjE5L0RvY3VtZW50
YXRpb24vZmlsZXN5c3RlbXMvcHJvYy50eHQJV2VkIE5vdiAgNyAyMzozOToz
NiAyMDAxDQorKysgbGludXgtMi40LjE5Lm5ldy9Eb2N1bWVudGF0aW9uL2Zp
bGVzeXN0ZW1zL3Byb2MudHh0CU1vbiBOb3YgIDQgMjA6NDg6NTIgMjAwMg0K
QEAgLTE1OTIsMTAgKzE1OTIsMTMgQEANCiBlcnJvcl9idXJzdCBhbmQgZXJy
b3JfY29zdA0KIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tDQogDQotVGhl
c2UgcGFyYW1ldGVycyAgYXJlIHVzZWQgdG8gbGltaXQgdGhlIHdhcm5pbmcg
bWVzc2FnZXMgd3JpdHRlbiB0byB0aGUga2VybmVsDQotbG9nIGZyb20gIHRo
ZSAgcm91dGluZyAgY29kZS4gIFRoZSAgaGlnaGVyIHRoZSBlcnJvcl9jb3N0
IGZhY3RvciBpcywgdGhlIGZld2VyDQotbWVzc2FnZXMgd2lsbCAgYmUgd3Jp
dHRlbi4gRXJyb3JfYnVyc3QgY29udHJvbHMgd2hlbiBtZXNzYWdlcyB3aWxs
IGJlIGRyb3BwZWQuDQotVGhlIGRlZmF1bHQgc2V0dGluZ3MgbGltaXQgd2Fy
bmluZyBtZXNzYWdlcyB0byBvbmUgZXZlcnkgZml2ZSBzZWNvbmRzLg0KK1Ro
ZXNlICBwYXJhbWV0ZXJzICBhcmUgdXNlZCB0byBsaW1pdCBob3cgbWFueSBJ
Q01QIGRlc3RpbmF0aW9uIHVucmVhY2hhYmxlIHRvIA0KK3NlbmQgIGZyb20g
IHRoZSAgaG9zdCAgaW4gcXVlc3Rpb24uIEl0IHdpbGwgYWxzbyBwcmludCBz
b21lIGVycm9yIG1lc3NhZ2VzIHRvIA0KK2tlcm5lbCAgbG9ncyAgaWYgIHNv
bWVvbmUgIGlzICBpZ25vcmluZyAgb3VyICBJQ01QICByZWRpcmVjdHMuIFRo
ZSBoaWdoZXIgdGhlIA0KK2Vycm9yX2Nvc3QgIGZhY3RvciAgaXMsICB0aGUg
ZmV3ZXIgZGVzdGluYXRpb24gdW5yZWFjaGFibGUgYW5kIGVycm9yIG1lc3Nh
Z2VzIA0KK3dpbGwgIGJlICBsZXQgIHRocm91Z2guICBFcnJvcl9idXJzdCAg
Y29udHJvbHMgIHdoZW4gIGRlc3RpbmF0aW9uIHVucmVhY2hhYmxlIA0KK21l
c3NhZ2VzICBhbmQgIGVycm9yICBtZXNzYWdlcyAgd2lsbCAgYmUgIGRyb3Bw
ZWQuIFRoZSBkZWZhdWx0IHNldHRpbmdzIGxpbWl0IA0KK3dhcm5pbmcgbWVz
c2FnZXMgdG8gZml2ZSBldmVyeSBzZWNvbmQuDQogDQogZmx1c2gNCiAtLS0t
LQ0K

---1463810815-1330789550-1036441714=:31688
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="2.5.45.docs.proc.txt.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0211042128341.31688@laptop1.agatha>
Content-Description: 
Content-Disposition: attachment; filename="2.5.45.docs.proc.txt.diff"

ZGlmZiAtdXIgbGludXgtMi41LjQ1Lm9sZC9Eb2N1bWVudGF0aW9uL2ZpbGVz
eXN0ZW1zL3Byb2MudHh0IGxpbnV4LTIuNS40NS9Eb2N1bWVudGF0aW9uL2Zp
bGVzeXN0ZW1zL3Byb2MudHh0DQotLS0gbGludXgtMi41LjQ1Lm9sZC9Eb2N1
bWVudGF0aW9uL2ZpbGVzeXN0ZW1zL3Byb2MudHh0CU1vbiBOb3YgIDQgMjE6
MDA6MzQgMjAwMg0KKysrIGxpbnV4LTIuNS40NS9Eb2N1bWVudGF0aW9uL2Zp
bGVzeXN0ZW1zL3Byb2MudHh0CU1vbiBOb3YgIDQgMjE6MTA6NDMgMjAwMg0K
QEAgLTE0NDUsMTAgKzE0NDUsMTMgQEANCiBlcnJvcl9idXJzdCBhbmQgZXJy
b3JfY29zdA0KIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tDQogDQotVGhl
c2UgcGFyYW1ldGVycyAgYXJlIHVzZWQgdG8gbGltaXQgdGhlIHdhcm5pbmcg
bWVzc2FnZXMgd3JpdHRlbiB0byB0aGUga2VybmVsDQotbG9nIGZyb20gIHRo
ZSAgcm91dGluZyAgY29kZS4gIFRoZSAgaGlnaGVyIHRoZSBlcnJvcl9jb3N0
IGZhY3RvciBpcywgdGhlIGZld2VyDQotbWVzc2FnZXMgd2lsbCAgYmUgd3Jp
dHRlbi4gRXJyb3JfYnVyc3QgY29udHJvbHMgd2hlbiBtZXNzYWdlcyB3aWxs
IGJlIGRyb3BwZWQuDQotVGhlIGRlZmF1bHQgc2V0dGluZ3MgbGltaXQgd2Fy
bmluZyBtZXNzYWdlcyB0byBvbmUgZXZlcnkgZml2ZSBzZWNvbmRzLg0KK1Ro
ZXNlICBwYXJhbWV0ZXJzICBhcmUgdXNlZCB0byBsaW1pdCBob3cgbWFueSBJ
Q01QIGRlc3RpbmF0aW9uIHVucmVhY2hhYmxlIHRvIA0KK3NlbmQgIGZyb20g
IHRoZSAgaG9zdCAgaW4gcXVlc3Rpb24uIEl0IHdpbGwgYWxzbyBwcmludCBz
b21lIGVycm9yIG1lc3NhZ2VzIHRvIA0KK2tlcm5lbCAgbG9ncyAgaWYgIHNv
bWVvbmUgIGlzICBpZ25vcmluZyAgb3VyICBJQ01QICByZWRpcmVjdHMuIFRo
ZSBoaWdoZXIgdGhlIA0KK2Vycm9yX2Nvc3QgIGZhY3RvciAgaXMsICB0aGUg
ZmV3ZXIgZGVzdGluYXRpb24gdW5yZWFjaGFibGUgYW5kIGVycm9yIG1lc3Nh
Z2VzIA0KK3dpbGwgIGJlICBsZXQgIHRocm91Z2guICBFcnJvcl9idXJzdCAg
Y29udHJvbHMgIHdoZW4gIGRlc3RpbmF0aW9uIHVucmVhY2hhYmxlIA0KK21l
c3NhZ2VzICBhbmQgIGVycm9yICBtZXNzYWdlcyAgd2lsbCAgYmUgIGRyb3Bw
ZWQuIFRoZSBkZWZhdWx0IHNldHRpbmdzIGxpbWl0IA0KK3dhcm5pbmcgbWVz
c2FnZXMgdG8gZml2ZSBldmVyeSBzZWNvbmQuDQogDQogZmx1c2gNCiAtLS0t
LQ0K

---1463810815-1330789550-1036441714=:31688--
