From: James Morris <jmorris@redhat.com>
Subject: Re: [RFC] SO_PEERSEC - security credentials for Unix stream sockets
Date: Fri, 12 Dec 2003 09:25:45 -0500 (EST)
Sender: linux-security-module-bounces@wirex.com
Message-ID: <Xine.LNX.4.44.0312120924410.2843-100000@thoron.boston.redhat.com>
References: <20031210145652.66bda4c2.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kuznet@ms2.inr.ac.ru, linux-security-module@wirex.com,
	sds@epoch.ncsc.mil, netdev@oss.sgi.com
Return-path: <linux-security-module-bounces@wirex.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031210145652.66bda4c2.davem@redhat.com>
List-Unsubscribe: <http://mail.wirex.com/mailman/listinfo/linux-security-module>,
	<mailto:linux-security-module-request@mail.wirex.com?subject=unsubscribe>
List-Archive: <http://mail.immunix.com/pipermail/linux-security-module>
List-Post: <mailto:linux-security-module@mail.wirex.com>
List-Help: <mailto:linux-security-module-request@mail.wirex.com?subject=help>
List-Subscribe: <http://mail.wirex.com/mailman/listinfo/linux-security-module>,
	<mailto:linux-security-module-request@mail.wirex.com?subject=subscribe>
Errors-To: linux-security-module-bounces@wirex.com
List-Id: netdev.vger.kernel.org

On Wed, 10 Dec 2003, David S. Miller wrote:

> I'm fine with this conceptually, although the earliest I could put
> this into the tree is 2.6.1 although I have a hunch that I'll be
> asked to defer something like this to 2.6.2, but who knows.

No problem, it will hopefully get more testing and feedback in the 
meantime.  I'll resubmit it sometime after 2.6.0.

> The one thing I don't like is the ifdef conditionalized member of
> the sock struct.  We should move away from config variables changing
> structure layouts.  Even a "void *sk_security;" would be better.

Ok.


- James
-- 
James Morris
<jmorris@redhat.com>
