From: Scott Mcdermott <smcdermott@questra.com>
Subject: Re: [IPSEC] Too many SADs!
Date: Tue, 22 Mar 2005 21:55:22 -0800
Message-ID: <20050323055520.GH13092@questra.com>
References: <200503220052.52756.wolfgang.walter@studentenwerk.mhn.de> <20050322224819.GB4924@questra.com> <20050323003310.GE8725@ns.snowman.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050323003310.GE8725@ns.snowman.net>
Resent-Message-Id: <20050328102302.AD87C13DE9@lujuria.roc.questra.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Frost on Tue 22/03 19:33 -0500:
> Sounds like I may need to check out strongswan/openswan.
> I can tell you I wasn't exactly a fan of freeswan for a
> variety of reasons.

What reasons? The userspace code with it is great (i.e. the
IKE daemon).  The kernel stuff may be a different matter.
You could use the native IPSEC code in the kernel instead.

I don't know what distribution you're using but I found it
simple to adapt the openswan .spec file to make a source RPM
for strongswan.

As I understand it, the Openswan project is motivated by
commercial interests, whereas Strongswan is in it for
security and correctness.  I had difficulty using Openswan
with AES (it wasn't accepting custom ciphers and DH groups
specified in the config file, and was sending bogus IKE
proposals with 65535 in all the fields of the first listed
transform) until I switched to Strongswan.  And if you are
doing anything with X.509, the author of that patch is the
one that forked Strongswan.  It has been very solid for me
since I switched off Racoon.
