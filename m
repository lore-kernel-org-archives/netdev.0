From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: make mandocs build failure with next-20150407
Date: Thu, 16 Apr 2015 09:43:50 +0200
Message-ID: <20150416094350.2cf7e38b@lwn.net>
References: <CA+r1Zhh1iwe4go+hOUwzngTphyareAvbooyRARihJa8LwbqHKg@mail.gmail.com>
	<CALLJCT3E7V9eZ_5-kFY1StQ4t6h73EuEyDc8wRpgm1fGJXNnAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: Jim Davis <jim.epost@gmail.com>, emmanuel.grumbach@intel.com,
	David Miller <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-doc <linux-doc@vger.kernel.org>, netdev@vger.kernel.org,
	johannes.berg@intel.com
To: Masanari Iida <standby24x7@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CALLJCT3E7V9eZ_5-kFY1StQ4t6h73EuEyDc8wRpgm1fGJXNnAg@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 16 Apr 2015 08:33:15 +0900
Masanari Iida <standby24x7@gmail.com> wrote:

> On Wed, Apr 8, 2015 at 7:41 AM, Jim Davis <jim.epost@gmail.com> wrote:
> >   DOCPROC Documentation/DocBook/80211.xml
> > Error(.//include/net/mac80211.h:329): Cannot parse enum!
> > Error(.//include/net/mac80211.h:367): Cannot parse enum!
> > Warning(.//include/net/mac80211.h:381): No description found for
> > parameter 'type'
> > --  
> 
> This error start to appear on Linus's tree.
> make xmldocs stops after this error.
> Then run it again,  make xmldocs process rest of the files.
> 
> Add TO:  netdev and patch authors for reporting the issue.

It's the result of some incomplete changes in the wireless tree; I sent a
fix to Johannes that he applied a couple of days ago.  Once that hits
mainline the problem should go away.

Thanks,

jon
