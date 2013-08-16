From: Andreas Jaeger <aj@suse.com>
Subject: Re: [GLIBC Patch v2] inet: avoid redefinition of some structs in
 kernel
Date: Fri, 16 Aug 2013 17:32:43 +0200
Message-ID: <520E461B.8040406@suse.com>
References: <1376558891-26221-1-git-send-email-amwang@redhat.com> <1376558891-26221-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Thomas Backlund <tmb@mageia.org>, libc-alpha@sourceware.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Carlos O'Donell <carlos@redhat.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <libc-alpha-return-42010-glibc-alpha=m.gmane.org@sourceware.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-##L=##H@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
In-Reply-To: <1376558891-26221-2-git-send-email-amwang@redhat.com>
List-Id: netdev.vger.kernel.org

On 08/15/2013 11:28 AM, Cong Wang wrote:
> From: Carlos O'Donell <carlos@redhat.com>
> 
> - Synchronize linux's `include/uapi/linux/in6.h' 
>   with glibc's `inet/netinet/in.h'.
> - Synchronize glibc's `inet/netinet/in.h with linux's
>   `include/uapi/linux/in6.h'.
> - Allow including the headers in either other.
> - First header included defines the structures and macros.

Let me first say that I really love where this is going and would love
to see more of this work.

Will this work with older kernels as well? Meaning: Can I compile
today's user land programs with a new glibc and Kernel 3.10? My reading
of the patch assumes it does but I would like to hear that you tested it.

The patch itself looks fine, thanks,
Andreas
-- 
 Andreas Jaeger aj@{suse.com,opensuse.org} Twitter/Identica: jaegerandi
  SUSE LINUX Products GmbH, Maxfeldstr. 5, 90409 Nürnberg, Germany
   GF: Jeff Hawn,Jennifer Guild,Felix Imendörffer,HRB16746 (AG Nürnberg)
    GPG fingerprint = 93A3 365E CE47 B889 DF7F  FED1 389A 563C C272 A126
