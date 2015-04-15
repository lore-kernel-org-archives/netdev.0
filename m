From: Masanari Iida <standby24x7@gmail.com>
Subject: Re: make mandocs build failure with next-20150407
Date: Thu, 16 Apr 2015 08:33:15 +0900
Message-ID: <CALLJCT3E7V9eZ_5-kFY1StQ4t6h73EuEyDc8wRpgm1fGJXNnAg@mail.gmail.com>
References: <CA+r1Zhh1iwe4go+hOUwzngTphyareAvbooyRARihJa8LwbqHKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-doc <linux-doc@vger.kernel.org>, netdev@vger.kernel.org,
	johannes.berg@intel.com
To: Jim Davis <jim.epost@gmail.com>, emmanuel.grumbach@intel.com,
	David Miller <davem@davemloft.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CA+r1Zhh1iwe4go+hOUwzngTphyareAvbooyRARihJa8LwbqHKg@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 8, 2015 at 7:41 AM, Jim Davis <jim.epost@gmail.com> wrote:
>   DOCPROC Documentation/DocBook/80211.xml
> Error(.//include/net/mac80211.h:329): Cannot parse enum!
> Error(.//include/net/mac80211.h:367): Cannot parse enum!
> Warning(.//include/net/mac80211.h:381): No description found for
> parameter 'type'
> --

This error start to appear on Linus's tree.
make xmldocs stops after this error.
Then run it again,  make xmldocs process rest of the files.

Add TO:  netdev and patch authors for reporting the issue.

Masanari

> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
