From: Keith Owens <kaos@ocs.com.au>
Subject: Re: [PATCH] LSM networking: skb hooks for 2.5.42 (2/7)
Date: Sat, 19 Oct 2002 12:33:07 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4301.1034994787@ocs3.intra.ocs.com.au>
References: <20021015.131037.96602290.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-security-module@wirex.com
In-reply-to: Your message of "Tue, 15 Oct 2002 13:10:37 MST."
             <20021015.131037.96602290.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Oct 2002 13:10:37 -0700 (PDT), 
"David S. Miller" <davem@redhat.com> wrote:
>   Yes, the size of the *.o files in the security directory can be shrunk a
>   bit:
>      text    data     bss     dec     hex filename
>      6765     776       8    7549    1d7d built-in.o
>      3280     392       4    3676     e5c capability.o
>      1772     384       0    2156     86c dummy.o
>      1713       0       4    1717     6b5 security.o
>   
>It's a whopping 32K on sparc64, and that is only counting
>the security/*.o objects.

<nitpick>
Double counting: built-in.o == (capability.o + dummy.o + security.o)
</nitpick>
