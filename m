From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: SO_REUSEADDR behavior different from BSD
Date: Thu, 5 Aug 2004 11:20:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFF4AEA4CE.6B3ED11C-ON88256EE7.0064248A-88256EE7.00648F67@us.ibm.com>
References: <19686.1091723777@www48.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: bert hubert <ahu@ds9a.nl>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <19686.1091723777@www48.gmx.net>
To: "Michael T Kerrisk" <mtk-lists@gmx.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael,
        Linux does not have SO_REUSEPORT, which post-Net/3
BSD systems do. I believe SO_REUSEADDR on Linux behaves
the same as 4.3BSD, but will differ with 4.4BSD and later because
of the addition of SO_REUSEPORT (unless there's a bug :-)).

                                        +-DLS
