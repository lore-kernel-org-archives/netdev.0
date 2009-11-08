From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v4 10/12] string: factorize skip_spaces
 and export it to be generally available
Date: Sun, 8 Nov 2009 16:50:00 +0000
Message-ID: <20091108165000.374714cb@lxorguk.ukuu.org.uk>
References: <cover.1257602781.git.andre.goddard@gmail.com>
	<c7d3b02b5e28eaa54a5360d57dfd177c44320187.1257602781.git.andre.goddard@gmail.com>
Reply-To: Linux filesystem caching discussion list <linux-cachefs@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-14
Content-Transfer-Encoding: quoted-printable
Cc: Andreas Dilger <adilger@sun.com>, Mike Snitzer <snitzer@redhat.com>,
	Takashi Iwai <tiwai@suse.de>, Kysela <perex@perex.cz>, Jan,
	Stefan Weinhuber <wein@de.ibm.com>,
	Eric Sandeen <sandeen@redhat.com>, "James E .
	J . Bottomley" <jejb@parisc-linux.org>, linux-cachefs@redhat.com,
	WANG Cong <wangcong@zeuux.org>, Len Brown <len.brown@intel.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Rusty Russell <rusty@rustcorp.com.au>, netfilter@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>,
	Engelhardt <jengelh@medozas.de>,
	Bjorn Helgaas <bjorn.helgaas@hp.com>, =?ISO-8859-14?B?QW5k?=, "Martin K .
	Petersen" <martin.petersen@oracle.com>, linux-kernel@vger.kernel.org,
	Stoyan Gaydarov <stoyboyker@gmail.com>, Kyle McMartin <kyle@mcmartin.ca>,
	netfilter-devel@vger.kernel.org, Joe Perches <joe@perches.com>,
	Andrew Morton <akpm@linux-foundation.org
To: =?ISO-8859-14?B?QW5kcuk=?= Goddard Rosa <andre.goddard@gmail.com>
Return-path: <linux-cachefs-bounces@redhat.com>
In-Reply-To: <c7d3b02b5e28eaa54a5360d57dfd177c44320187.1257602781.git.andre.goddard@gmail.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-cachefs>,
	<mailto:linux-cachefs-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-cachefs>
List-Post: <mailto:linux-cachefs@redhat.com>
List-Help: <mailto:linux-cachefs-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-cachefs>,
	<mailto:linux-cachefs-request@redhat.com?subject=subscribe>
Sender: linux-cachefs-bounces@redhat.com
Errors-To: linux-cachefs-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Sat,  7 Nov 2009 13:16:18 -0200
Andr=E9 Goddard Rosa <andre.goddard@gmail.com> wrote:

> On the following sentence:
>     while (*s && isspace(*s))
>         s++;

Looks fine but for one thing: it's actually shorter inline than moved
into /lib so at the very least it should be a header inline not a
function call.

Second minor comment. Although it never made it into the final ANSI C,
the proposed name (and the one used in a lot of other non Linux code for
this) is stpblk().

Alan
